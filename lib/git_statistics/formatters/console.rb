module GitStatistics
  module Formatters
    class Console

      attr_accessor :commits

      def initialize(commits)
        @commits = commits
      end

      def prepare_result_summary(sort, email, top_n = 0)
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
        config
      end

      def print_summary(sort, email, top_n = 0)
        # Prepare and determine the config for the result summary based on parameters
        commit_totals = @commits.totals
        config = prepare_result_summary(sort, email, top_n)

        # Print query/header information
        output = print_header(config)

        # Print per author information
        config[:data].each do |key,value|
          output << config[:pattern] % [key, "", value[:commits], value[:additions],
                          value[:deletions], value[:create], value[:delete],
                          value[:rename], value[:copy], value[:merges]]
          output << "\n"
          output << print_language_data(config[:pattern], value)
        end

        # Reprint query/header for repository information
        output << "\n"
        output << print_header(config)
        output << config[:pattern] % ["Repository Totals", "", commit_totals[:commits],
                        commit_totals[:additions], commit_totals[:deletions], commit_totals[:create],
                        commit_totals[:delete], commit_totals[:rename], commit_totals[:copy], commit_totals[:merges]]
        output << "\n"
        output += print_language_data(config[:pattern], commit_totals)
        output
      end

      def print_language_data(pattern, data)
        output = ""
        # Print information of each language for the data
        data[:languages].each do |key,value|
          output << pattern % ["", key, "", value[:additions], value[:deletions],
                          value[:create], value[:delete], value[:rename],
                          value[:copy], value[:merges]]
          output << "\n"
        end

        output
      end

      def print_header(config)
        output = get_author_info(config, @commits.stats.size)
        output << get_header_info(config)
        output << "\n"
        output
      end

      def get_header_info(config)
        top_and_bottom = "-"*87 + "-"*config[:author_length] + "-"*config[:language_length]
        headers = [top_and_bottom]
        headers << config[:pattern] % ['Name/Email', 'Language', 'Commits', 'Additions', 'Deletions', 'Creates', 'Deletes', 'Renames', 'Copies', 'Merges']
        headers << top_and_bottom
        headers.join("\n")
      end

      def get_author_info(config, total_authors)
        if config[:top_n] > 0 && config[:top_n] < total_authors
          return "Top #{config[:top_n]} authors(#{total_authors}) sorted by #{config[:sort]}\n"
        end

        "All authors(#{total_authors}) sorted by #{config[:sort]}\n"
      end
    end
  end
end
