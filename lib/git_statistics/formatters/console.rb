module GitStatistics
  module Formatters
    class Console

      attr_accessor :commits, :config

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
        @config = {:data => data,
                  :author_length => Utilities.max_length_in_list(data.keys, 17),
                  :language_length => Utilities.max_length_in_list(@commits.totals[:languages].keys, 8),
                  :sort => sort,
                  :email => email,
                  :top_n => top_n}

        # Acquire formatting pattern for output
        @pattern = "| %-#{config[:author_length]}s | %-#{config[:language_length]}s | %7s | %9s | %9s | %7s | %7s | %7s | %6s | %6s |"
        config
      end

      def print_summary(sort, email, top_n = 0)
        # Prepare and determine the config for the result summary based on parameters
        commit_totals = @commits.totals
        config = prepare_result_summary(sort, email, top_n)

        # Print query/header information
        output = print_header

        # Print per author information
        config[:data].each do |name, commit_data|
          output << print_row(name, commit_data)
          output << print_language_data(commit_data)
        end
        output << separator
        output << print_row("Repository Totals", commit_totals)
        output << print_language_data(commit_totals)
        output.flatten.join("\n")
      end

      def print_language_data(data)
        output = []
        # Print information of each language for the data
        data[:languages].each do |language, commit_data|
          output << print_row("", commit_data, language)
        end
        output
      end

      def print_row(name, commit_info, language = '')
        format_for_row(name, language, commit_info[:commits],
                        commit_info[:additions], commit_info[:deletions], commit_info[:create],
                        commit_info[:delete], commit_info[:rename], commit_info[:copy], commit_info[:merges])
      end

      def print_header
        output = []
        output << get_author_info(@commits.stats.size)
        output << get_header_info
        output
      end

      def get_header_info
        headers = []
        headers << separator
        headers << format_for_row('Name/Email', 'Language', 'Commits', 'Additions', 'Deletions', 'Creates', 'Deletes', 'Renames', 'Copies', 'Merges')
        headers << separator
        headers
      end

      def format_for_row(*columns)
        @pattern % columns
      end

      def separator
        "-" * 89 + "-"*config[:author_length] + "-"*config[:language_length]
      end

      def get_author_info(total_authors)
        if config[:top_n] > 0 && config[:top_n] < total_authors
          return "Top #{config[:top_n]} authors(#{total_authors}) sorted by #{config[:sort]}"
        end

        "All authors(#{total_authors}) sorted by #{config[:sort]}"
      end
    end
  end
end
