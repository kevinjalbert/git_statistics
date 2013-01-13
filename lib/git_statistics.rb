require 'git_statistics/initialize'

module GitStatistics
  class GitStatistics
    def initialize(args = nil)
      @opts = Trollop::options do
        opt :email, "Use author's email instead of name", :default => false
        opt :merges, "Factor in merges when calculating statistics", :default => false
        opt :pretty, "Save the commits in git_repo/.git_statistics in pretty print (larger file size)", :default => false
        opt :update, "Update saved commits with new data", :default => false
        opt :sort, "Sort authors by {commits, additions, deletions, create, delete, rename, copy, merges}", :default => "commits"
        opt :top, "Show the top N authors in results", :default => 0
        opt :branch, "Use current branch for statistics (otherwise all branches)", :default => false
        opt :verbose, "Verbose output (shows progress)", :default => false
        opt :limit, "The maximum limit of commits to hold in memory at a time", :default => 100
      end
    end

    def execute
      # Collect data (incremental or fresh) based on presence of old data
      if @opts[:update]
        # Ensure commit directory is present
        collector = Collector.new(@opts[:verbose], @opts[:limit], false, @opts[:pretty])
        commits_directory = collector.repo_path + ".git_statistics" + File::Separator
        FileUtils.mkdir_p(commits_directory)
        file_count = Utilities.number_of_matching_files(commits_directory, /\d+\.json/) - 1

        # Only use --since if there is data present
        if file_count >= 0
          time = Utilities.get_modified_time(commits_directory + "#{file_count}.json")
          collector.collect(@opts[:branch], "--since=\"#{time}\"")
          collected = true
        end
      end

      # If no data was collected as there was no present data then start fresh
      unless collected
        collector = Collector.new(@opts[:verbose], @opts[:limit], true, @opts[:pretty])
        collector.collect(@opts[:branch])
      end

      # Calculate statistics
      collector.commits.calculate_statistics(@opts[:email], @opts[:merges])

      # Print results
      results = Results.new(collector.commits)
      puts results.print_summary(@opts[:sort], @opts[:email], @opts[:top])
    end
  end

end
