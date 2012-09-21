module GitStatistics
  class Commits < Hash

    attr_accessor :stats, :author_list, :language_list, :totals, :path, :fresh

    def initialize(path, fresh)
      super()
      @path = path
      @fresh = fresh
      clean
    end

    def clean
      # Ensure the path exists
      FileUtils.mkdir_p(@path)

      # Remove all files within path if saving
      if @fresh
        Dir.entries(@path).each do |file|
          next if file == "." || file == ".."
          File.delete(path + File::Separator + file)
        end
      end

      # Initilize/resets stats and totals
      @stats = Hash.new
      @totals = Hash.new(0)
      @totals[:languages] = {}
    end

    def flush_commits(force=false)
      file_count = Dir.entries(path).size - 2
      save(path + File::Separator + file_count.to_s + ".json", false)
      self.clear
    end

    def author_top_n_type(type, top_n=0)
      top_n = 0 if top_n < 0
      return nil if @stats.size == 0
      return nil if !@stats.first[1].has_key?(type)
      return Hash[*@stats.sorted_hash {|a,b| b[1][type.to_sym] <=> a[1][type]}.to_a[0..top_n-1].flatten]
    end

    def calculate_statistics(email, merge)
      # Identify authors and author type
      if email
        type = :author_email
      else
        type = :author
      end

      # For all the commit files created
      Dir.entries(path).each do |file|
        next if file == "." || file == ".."

        # Load commit file and extract the commits
        load(path + File::Separator + file)
        process_commits(type, merge)
        self.clear
      end
    end

    def process_commits(type, merge)
      # Collect the stats from each commit
      self.each do |key,value|
        if !merge && value[:merge]
          next
        else

          # Acquire author (make if not seen before)
          author = @stats[value[type]]

          if author == nil
            @stats[value[type]] = Hash.new(0)
            author = @stats[value[type]]
            author[:languages] = {}
          end

          # If there are no changed files move to next commit
          next if value[:files].size == 0

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
    end

    def add_language_stats(data, file)
      # Add stats to data's languages
      if data[:languages][file[:language].to_sym] == nil
        data[:languages][file[:language].to_sym] = Hash.new(0)
      end

      data[:languages][file[:language].to_sym][:additions] += file[:additions]
      data[:languages][file[:language].to_sym][:deletions] += file[:deletions]

      if file[:status] != nil
        data[:languages][file[:language].to_sym][file[:status].to_sym] += 1
      end

      return data
    end

    def add_commit_stats(data, commit)
      # Add commit stats to author
      data[:merges] += 1 if commit[:merge]
      data[:commits] += 1
      data[:additions] += commit[:additions]
      data[:deletions] += commit[:deletions]
      data[:create] += commit[:create] if commit[:create] != nil
      data[:delete] += commit[:delete] if commit[:delete] != nil
      data[:rename] += commit[:rename] if commit[:rename] != nil
      data[:copy] += commit[:copy] if commit[:copy] != nil
      return data
    end

    def load(file)
      self.merge!(JSON.parse(File.read(file), :symbolize_names => true))
    end

    def save(file, pretty)
      # Ensure the path to the file exists
      FileUtils.mkdir_p(File.dirname(file))

      # Save file in a simple or pretty format
      if pretty
        File.open(file, 'w') {|file| file.write(JSON.pretty_generate(self))}
      else
        File.open(file, 'w') {|file| file.write(self.to_json)}
      end
    end
  end

  class Hash < Hash
    def sorted_hash(&block)
      self.class[sort(&block)]
    end
  end
end
