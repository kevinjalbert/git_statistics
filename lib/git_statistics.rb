require 'git_statistics/initialize'

module GitStatistics
  class CLI
    attr_reader :repository, :options

    DEFAULT_BRANCH = 'master'

    def initialize(dir)
      @repository = dir.nil? ? Rugged::Repository.discover(Dir.pwd) : Rugged::Repository.discover(dir)
      @collected = false
      @collector = nil
      @options = OpenStruct.new(
        email: false,
        merges: false,
        pretty: false,
        update: false,
        sort: 'commits',
        top: 0,
        branch: DEFAULT_BRANCH,
        verbose: false,
        debug: false,
        limit: 100
      )
      parse_options
    end

    def execute
      determine_log_level
      collect_and_only_update
      fresh_collect! unless @collected
      calculate!
      output_results
    end

    def collect_and_only_update
      return unless options.update

      # Ensure commit directory is present
      @collector = Collector.new(repository, options.limit, false, options.pretty)
      commits_directory = repository.workdir + '.git_statistics/'
      FileUtils.mkdir_p(commits_directory)
      file_count = Utilities.number_of_matching_files(commits_directory, /\d+\.json/) - 1

      return unless file_count >= 0

      time_since = Utilities.get_modified_time(commits_directory + "#{file_count}.json").to_s
      @collector.collect(branch: options.branch, time_since: time_since)
      @collected = true
    end

    def calculate!
      @collector.commits.calculate_statistics(options.email, options.merges)
    end

    def output_results
      results = Formatters::Console.new(@collector.commits)
      puts results.print_summary(options.sort, options.email, options.top)
    end

    def fresh_collect!
      @collector = Collector.new(repository, options.limit, true, options.pretty)
      @collector.collect(branch: options.branch)
    end

    def parse_options
      OptionParser.new do |opt|
        opt.version = VERSION
        opt.on '-e', '--email', "Use author's email instead of name" do
          options.email = true
        end
        opt.on '-m', '--merges', 'Factor in merges when calculating statistics' do
          options.merges = true
        end
        opt.on '-p', '--pretty', 'Save the commits in git_repo/.git_statistics in pretty print (larger file size)' do
          options.pretty = true
        end
        opt.on '-u', '--update', 'Update saved commits with new data' do
          options.update = true
        end
        opt.on '-s', '--sort TYPE', 'Sort authors by {commits, additions, deletions, create, delete, rename, copy, merges}' do |type|
          options.sort = type
        end
        opt.on '-t', '--top N', Float, 'Show the top N authors in results' do |value|
          options.top = value
        end
        opt.on '-b', '--branch BRANCH', 'Use the specified branch for statistics (otherwise the master branch is used)' do |branch|
          options.branch = branch
        end
        opt.on '-v', '--verbose', 'Verbose output (shows INFO level log statements)' do
          options.verbose = true
        end
        opt.on '-d', '--debug', 'Debug output (shows DEBUG level log statements)' do
          options.debug = true
        end
        opt.on '-l', '--limit MAX_COMMITS', Float, 'The maximum limit of commits to hold in memory at a time' do |number|
          options.limit = number
        end
      end.parse!
    end

    private

    def determine_log_level
      if options.debug
        Log.level = Logger::DEBUG
        Log.use_debug
      elsif options.verbose
        Log.level = Logger::INFO
      end
    end
  end
end
