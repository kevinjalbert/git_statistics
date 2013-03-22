require 'ostruct'
require 'optparse'
require 'git_statistics/initialize'

module GitStatistics
  class GitStatistics
    attr_reader :options
    def initialize
      @options = OpenStruct.new(
        email: false,
        merges: false,
        pretty: false,
        update: false,
        sort: "commits",
        top: 0,
        branch: false,
        verbose: false,
        limit: 100
      )
      parse_options
    end

    def execute
      Log.level = Logger::INFO if options.verbose

      # Collect data (incremental or fresh) based on presence of old data
      if options.update
        # Ensure commit directory is present
        collector = Collector.new(options.limit, false, options.pretty)
        commits_directory = File.join(collector.repo_path, ".git_statistics")
        FileUtils.mkdir_p(commits_directory)
        file_count = Utilities.number_of_matching_files(commits_directory, /\d+\.json/) - 1

        # Only use --since if there is data present
        if file_count >= 0
          time = Utilities.get_modified_time(commits_directory + "#{file_count}.json")
          collector.collect(options.branch, "--since=\"#{time}\"")
          collected = true
        end
      end

      # If no data was collected as there was no present data then start fresh
      unless collected
        collector = Collector.new(options.limit, true, options.pretty)
        collector.collect(options.branch)
      end

      # Calculate statistics
      collector.commits.calculate_statistics(options.email, options.merges)

      # Print results
      results = Formatters::Console.new(collector.commits)
      puts results.print_summary(options.sort, options.email, options.top)
    end

    def parse_options
      OptionParser.new do |opt|
        opt.on "-e", "--email", "Use author's email instead of name" do
          options.email = true
        end
        opt.on "-m", "--merges", "Factor in merges when calculating statistics" do
          options.merges = true
        end
        opt.on "-p", "--pretty", "Save the commits in git_repo/.git_statistics in pretty print (larger file size)" do
          options.pretty = true
        end
        opt.on "-u", "--update", "Update saved commits with new data" do
          options.update = true
        end
        opt.on "-s", "--sort TYPE", "Sort authors by {commits, additions, deletions, create, delete, rename, copy, merges}" do |type|
          options.sort = type
        end
        opt.on "-t", "--top N", Float,"Show the top N authors in results" do |value|
          options.top = value
        end
        opt.on "-b", "--branch", "Use current branch for statistics (otherwise all branches)" do
          options.branch = true
        end
        opt.on "-v", "--verbose", "Verbose output (shows progress)" do
          options.verbose = true
        end
        opt.on "-l", "--limit MAX_COMMITS", Float, "The maximum limit of commits to hold in memory at a time" do |number|
          options.limit = number
        end
      end.parse!
    end
  end

end
