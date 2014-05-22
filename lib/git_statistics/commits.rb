module GitStatistics
  class Commits < Hash
    attr_accessor :stats, :totals, :path, :fresh, :limit, :pretty

    def initialize(path, fresh, limit, pretty)
      super()
      @path = path
      @fresh = fresh
      @limit = limit
      @pretty = pretty
      clean
    end

    def clean
      # Ensure the path exists
      FileUtils.mkdir_p(path)

      # Remove all files within path if saving
      if fresh
        files_in_path.each do |file|
          File.delete(File.join(path, file))
        end
      end

      # Initilize/resets stats and totals
      @stats = Hash.new
      @totals = Hash.new(0)
      @totals[:languages] = {}
    end

    def files_in_path
      Dir.entries(path).reject { |file| %w(. ..).include?(file) }
    end

    def flush_commits(force = false)
      return unless size >= limit || force

      file_count = Utilities.number_of_matching_files(path, /\d+\.json/)
      save(File.join(path, "#{file_count}.json"), @pretty)
      clear
    end

    def author_top_n_type(type, top_n = 0)
      top_n = 0 if top_n < 0
      if @stats.empty? || !@stats.first[1].key?(type)
        nil
      else
        Hash[*@stats.sorted_hash { |a, b| b[1][type.to_sym] <=> a[1][type] }.to_a[0..top_n - 1].flatten]
      end
    end

    def calculate_statistics(email, merge)
      # Identify authors and author type
      type = email ? :author_email : :author

      # Process the commits from file or memory
      files = Dir.entries(path) - ['.', '..']
      if files.size == 0
        process_commits(type, merge)
      else
        # Load commit file and extract the commits
        files.each do |file|
          next unless file =~ /\d+\.json/

          load(File.join(path, file))
          process_commits(type, merge)
          clear
        end
      end
    end

    def process_commits(type, merge)
      # Collect the stats from each commit
      each do |key, value|
        next if !merge && value[:merge]
        # If there are no changed files move to next commit
        next if value[:files].empty?

        # Acquire author (make if not seen before)
        author = @stats[value[type]]

        if author.nil?
          @stats[value[type]] = Hash.new(0)
          author = @stats[value[type]]
          author[:languages] = {}
        end

        # Collect language stats
        value[:files].each do |file|

          # Add to author's languages
          add_language_stats(author, file)

          # Add to repository's languages
          add_language_stats(@totals, file)
        end

        # Add commit stats to author
        add_commit_stats(author, value)

        # Add commit stats to repository
        add_commit_stats(@totals, value)

        # Save new changes back to stats
        @stats[value[type]] = author
        author = nil
      end
    end

    def add_language_stats(data, file)
      # Add stats to data's languages
      if data[:languages][file[:language].to_sym].nil?
        data[:languages][file[:language].to_sym] = Hash.new(0)
      end

      data[:languages][file[:language].to_sym][:additions] += file[:additions]
      data[:languages][file[:language].to_sym][:deletions] += file[:deletions]

      # Keep count of languages status (i.e., added, deleted) and keep keys consistent (i.e., added_files, deleted_files)
      unless file[:status].nil?
        data[:languages][file[:language].to_sym][(file[:status] + '_files').to_sym] += 1
      end

      data
    end

    def add_commit_stats(data, commit)
      # Add commit stats to author
      data[:merges] += 1 if commit[:merge]
      data[:commits] += 1
      data[:additions] += commit[:additions]
      data[:deletions] += commit[:deletions]
      data[:added_files] += commit[:added_files] unless commit[:added_files].nil?
      data[:deleted_files] += commit[:deleted_files] unless commit[:deleted_files].nil?
      data
    end

    def load(file)
      merge!(JSON.parse(File.read(file), symbolize_names: true))
    end

    def save(file, pretty)
      return if empty?

      # Ensure the path to the file exists
      FileUtils.mkdir_p(File.dirname(file))

      # Save file in a simple or pretty format
      File.open(file, 'w') do |f|
        json_content = pretty ? JSON.pretty_generate(self) : to_json
        f.write(json_content)
      end
    end
  end

  class Hash < Hash
    def sorted_hash(&block)
      self.class[sort(&block)]
    end
  end
end
