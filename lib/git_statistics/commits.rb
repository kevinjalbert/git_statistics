module GitStatistics
  class Commits < Hash

    attr_accessor :stats, :author_list, :language_list, :totals

    def initialize
      super
      @stats = Hash.new(0)
      @author_list = []
      @language_list = []
      @totals = Hash.new(0)
      @totals[:languages] = {}
    end

    def identify_authors
      self.each do |key,value|
        if not @author_list.include?(value[:author])
          @author_list << value[:author]
        end
      end
    end

    def identify_authors_email
      self.each do |key,value|
        if not @author_list.include?(value[:author_email])
          @author_list << value[:author_email]
        end
      end
    end

    def author_top_n_type(type, n=0)
      n = 0 if n < 0
      return nil if @stats == nil || !@stats.first[1].has_key?(type)
      return @stats.sorted_hash {|a,b| b[1][type.to_sym] <=> a[1][type]}.to_a[0..n-1]
    end

    def calculate_statistics(email, merge)

      # Identify authors and author type
      if email
        identify_authors_email
        type = :author_email
      else
        identify_authors
        type = :author
      end

      # Initialize the stats hash
      @author_list.each do |author|
        @stats[author] = Hash.new(0)
        @stats[author][:languages] = {}
      end

      # Collect the stats from each commit
      self.each do |key,value|
        if not merge and value[:merge]
          next
        else

          author = (@stats[value[type]] ||= Hash.new(0))

          # Collect language stats
          value[:files].each do |file|

            # Add to author's languages
            add_language_stats(author, file)

            # Add to repository's languages
            add_language_stats(@totals, file)

            # Add language to language list if not encountered before
            if not @language_list.include?(file[:language])
              @language_list << file[:language]
            end
          end

          # Add commit stats to author
          add_commit_stats(author, value)

          # Add commit stats to repository
          add_commit_stats(@totals, value)
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
      if file[:status] != nil || file[:status] == "submodule"
        data[:languages][file[:language].to_sym][file[:status].to_sym] += 1
      end
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
