module GitStatistics
  module Formatters
    class Console
      attr_reader :output
      attr_accessor :commits, :config

      def initialize(commits)
        @commits = commits
        @config = {}
        @output = []
      end

      def prepare_result_summary(sort, email, top_n = 0)
        # Default to a 0 if given a negative number to display
        top_n = 0 if top_n < 0

        # Acquire data based on sort type and top # to show
        data = @commits.author_top_n_type(sort.to_sym, top_n)
        raise 'Parameter for --sort is not valid' if data.nil?

        # Create config
        @config = { data: data,
                    author_length: Utilities.max_length_in_list(data.keys, 17),
                    language_length: Utilities.max_length_in_list(@commits.totals[:languages].keys, 8),
                    sort: sort,
                    email: email,
                    top_n: top_n }

        # Acquire formatting pattern for output
        @pattern = "| %-#{config[:author_length]}s | %-#{config[:language_length]}s | %7s | %9s | %9s | %7s | %7s | %7s | %6s | %6s |"
        @config
      end

      def print_summary(sort, email, top_n = 0)
        # Prepare and determine the config for the result summary based on parameters
        commit_totals = @commits.totals
        config = prepare_result_summary(sort, email, top_n)

        # Print query/header information
        print_header

        # Print per author information
        config[:data].each do |name, commit_data|
          print_row(name, commit_data)
          print_language_data(commit_data)
        end

        add_row separator

        print_row('Repository Totals', commit_totals)
        print_language_data(commit_totals)
        add_row separator

        display!
      end

      def display!
        output.join("\n")
      end

      def print_language_data(data)
        # Print information of each language for the data
        data[:languages].sort.each do |language, commit_data|
          print_row('', commit_data, language)
        end
        output
      end

      def print_row(name, commit_info, language = '')
        add_row format_for_row(name, language, commit_info[:commits],
                               commit_info[:additions], commit_info[:deletions], commit_info[:added_files],
                               commit_info[:deleted_files], commit_info[:renamed_files], commit_info[:copied_files], commit_info[:merges])
      end

      def print_header
        author_info(@commits.stats.size)
        header_info
      end

      def header_info
        add_row separator
        add_row format_for_row('Name/Email', 'Language', 'Commits', 'Additions', 'Deletions', 'Creates', 'Deletes', 'Renames', 'Copies', 'Merges')
        add_row separator
      end

      def format_for_row(*columns)
        @pattern % columns
      end

      def separator
        ('-' * 89) + ('-' * config[:author_length]) + ('-' * config[:language_length])
      end

      def author_info(total_authors)
        if config[:top_n] > 0 && config[:top_n] < total_authors
          add_row "Top #{config[:top_n]} authors(#{total_authors}) sorted by #{config[:sort]}"
        else
          add_row "All authors(#{total_authors}) sorted by #{config[:sort]}"
        end
      end

      def add_row(string_or_array)
        output.concat Array(string_or_array)
      end
    end
  end
end
