module GitStatistics
  class Commits < Hash

    attr_accessor :author_list, :data_authors, :data_authors_email, :totals

    def initialize
      super
    end

    def authors
      author_list = []
      self.each do |key,value|
        if not author_list.include?(value[:author])
          author_list << value[:author]
        end
      end
      return author_list
    end

    def authors_email
      author_list = []
      self.each do |key,value|
        if not author_list.include?(value[:author_email])
          author_list << value[:author_email]
        end
      end
      return author_list
    end

    def authors_statistics(email, merge)

      # Identify authors and author type
      if email
        @author_list = authors_email
        type = :author_email
      else
        @author_list = authors
        type = :author
      end

      # Initialize the stats hash
      stats = Hash.new
      @author_list.each do |author|
        stats[author] = Hash.new
        stats[author][:commits] = 0
        stats[author][:insertions] = 0
        stats[author][:deletions] = 0
        stats[author][:creates] = 0
        stats[author][:deletes] = 0
        stats[author][:renames] = 0
        stats[author][:copies] = 0
        stats[author][:merges] = 0
      end

      # Collect the stats for each author
      self.each do |key,value|
        if not merge and value[:merge]
          next
        else
          stats[value[type]][:merges] += 1 if value[:merge]
          stats[value[type]][:commits] += 1
          stats[value[type]][:insertions] += value[:insertions]
          stats[value[type]][:deletions] += value[:deletions]
          stats[value[type]][:creates] += value[:creates]
          stats[value[type]][:deletes] += value[:deletes]
          stats[value[type]][:renames] += value[:renames]
          stats[value[type]][:copies] += value[:copies]
        end
      end
      return stats
    end

    def author_top_n_type(email, type, n=0)
      n = 0 if n < 0

      if email
        data = @data_authors_email
      else
        data = @data_authors
      end

      return nil if data == nil || !data.first[1].has_key?(type)
      return data.sorted_hash {|a,b| b[1][type.to_sym] <=> a[1][type]}.to_a[0..n-1]
    end

    def calculate_statistics(email, merge)

      # Calculate author statistics
      @data_authors_email = authors_statistics(true, merge) if email
      @data_authors = authors_statistics(false, merge) if not email

      # Calculate totals
      @totals = Hash.new(0)
      self.each do |key,value|
        if not merge and value[:merge]
          next
        else
          @totals[:merges] += 1 if value[:merge]
          @totals[:commits] += 1
          @totals[:insertions] += value[:insertions]
          @totals[:deletions] += value[:deletions]
          @totals[:creates] += value[:creates]
          @totals[:deletes] += value[:deletes]
          @totals[:renames] += value[:renames]
          @totals[:copies] += value[:copies]
        end
      end
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
