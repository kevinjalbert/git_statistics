module GitStatistics
  class Results

    attr_accessor :commits

    def initialize(commits)
      @commits = commits
    end

    def prepare_result_summary(sort, email, top_n=0)
      # Default to a 0 if given a negative number to display
      top_n = 0 if top_n < 0

      # Acquire data based on sort type and top # to show
      data = @commits.author_top_n_type(sort.to_sym, top_n)
      raise "Parameter for --sort is not valid" if data.nil?

      # Create config
      config = {:data => data,
                :author_length => Utilities.max_length_in_list(data.keys, 17),
                :language_length => Utilities.max_length_in_list(@commits.totals[:languages].keys, 8),
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
      output = print_header(config)

      # Print per author information
      config[:data].each do |key,value|
        output += config[:pattern] % [key, "", value[:commits], value[:additions],
                        value[:deletions], value[:create], value[:delete],
                        value[:rename], value[:copy], value[:merges]]
        output += "\n"
        output += print_language_data(config[:pattern], value)
      end

      # Reprint query/header for repository information
      output += "\n"
      output += print_header(config)
      data = @commits.totals
      output += config[:pattern] % ["Repository Totals", "", data[:commits],
                      data[:additions], data[:deletions], data[:create],
                      data[:delete], data[:rename], data[:copy], data[:merges]]
      output += "\n"
      output += print_language_data(config[:pattern], data)
      return output
    end

    def print_language_data(pattern, data)
      output = ""
      # Print information of each language for the data
      data[:languages].each do |key,value|
        output += pattern % ["", key, "", value[:additions], value[:deletions],
                        value[:create], value[:delete], value[:rename],
                        value[:copy], value[:merges]]
        output += "\n"
      end
      return output
    end

    def print_header(config)
      total_authors = @commits.stats.size

      output = ""
      # Print summary information of displayed results
      if config[:top_n] > 0 and config[:top_n] < total_authors
        output += "Top #{config[:top_n]} authors(#{total_authors}) sorted by #{config[:sort]}\n"
      else
        output += "All authors(#{total_authors}) sorted by #{config[:sort]}\n"
      end

      # Print column headers
      output += "-"*87 + "-"*config[:author_length] + "-"*config[:language_length]
      output += "\n"
      output += config[:pattern] % ['Name/Email', 'Language', 'Commits', 'Additions', 'Deletions', 'Creates', 'Deletes', 'Renames', 'Copies', 'Merges']
      output += "\n"
      output +=  "-"*87 + "-"*config[:author_length] + "-"*config[:language_length]
      output += "\n"
      return output
    end
  end
end

