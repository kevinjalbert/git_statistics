module GitStatistics
  class Results

    attr_accessor :commits

    def initialize(commits)
      @commits = commits
    end

    def find_longest_author(data)
      # Find the longest author name/email (for string formatting)
      total_authors = @commits.author_list.length
      author_length = 17
      data.each do |key,value|
        author_length = key.length if key.length > author_length
      end
      return author_length
    end

    def find_longest_language(data)
      # Find the longest language name (for string formatting)
      total_language = @commits.language_list.length
      language_length = 9
      @commits.language_list.each do |key,value|
        language_length = key.length if key.length > language_length
      end
      return language_length
    end

    def prepare_result_summary(sort, email, top_n)
      # Default to a 0 if given a negative number to display
      top_n = 0 if top_n < 0

      # Acquire data based on sorty type and top # to show
      data = @commits.author_top_n_type(sort.to_sym, top_n)
      if data == nil
        raise "Parameter for --sort is not valid"
      end

      # Create config
      config = {:data => data,
                       :author_length => find_longest_author(data),
                       :language_length => find_longest_language(data),
                       :sort => sort,
                       :email => email,
                       :top_n => top_n}

      # Acquire formatting pattern for output
      pattern = "%-#{config[:author_length]}s | %-#{config[:language_length]}s | %7s | %9s | %9s | %7s | %7s | %7s | %6s | %6s |"
      config[:pattern] = pattern
      return config
    end

    def print_summary(sort, email, top_n=0)
      # Prepare and determine the config for the result summary based on parameters
      config = prepare_result_summary(sort, email, top_n)

      # Print query/header information
      print_header(config)

      # Print per author information
      config[:data].each do |key,value|
        puts config[:pattern] % [key, "", value[:commits], value[:additions],
                        value[:deletions], value[:create], value[:delete],
                        value[:rename], value[:copy], value[:merges]]
        print_language_data(config[:pattern], value)
      end

      # Reprint query/header for repository information
      print_header(config)
      data = @commits.totals
      puts config[:pattern] % ["Repository Totals", "", data[:commits],
                      data[:additions], data[:deletions], data[:create],
                      data[:delete], data[:rename], data[:copy], data[:merges]]
      print_language_data(config[:pattern], data)
    end

    def print_language_data(pattern, data)
      # Print information of each language for the data
      data[:languages].each do |key,value|
        puts pattern % ["", key, "", value[:additions], value[:deletions],
                        value[:create], value[:delete], value[:rename],
                        value[:copy], value[:merges]]
      end
    end

    def print_header(config)
      total_authors = @commits.author_list.length

      # Print summary information of displayed results
      if config[:top_n] > 0 and config[:top_n] < total_authors
        puts "\nTop #{config[:top_n]} authors(#{total_authors}) sorted by #{config[:sort]}\n"
      else
        puts "\nAll authors(#{total_authors}) sorted by #{config[:sort]}\n"
      end

      # Print column headers
      puts "-"*87 + "-"*config[:author_length] + "-"*config[:language_length]
      puts config[:pattern] % ['Name/Email', 'Language', 'Commits', 'Additions', 'Deletions', 'Creates', 'Deletes', 'Renames', 'Copies', 'Merges']
      puts "-"*87 + "-"*config[:author_length] + "-"*config[:language_length]
    end
  end
end

