require 'git_statistics/initialize'

module GitStatistics
  class GitStatistics
    def initialize(args=nil)
      @opts = Trollop::options do
        opt :email, "Use author's email instead of name", :default => false
        opt :merges, "Factor in merges when calculating statistics", :default => false
        opt :save, "Save the commits in git_repo/.git_statistics", :default => false
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
      # Create a collector that will reuse or start fresh
      if (@opts[:pretty] || @opts[:save]) && !@opts[:update]
        collector = Collector.new(@opts[:verbose], @opts[:limit], true)
      else
        collector = Collector.new(@opts[:verbose], @opts[:limit], false)
      end

      # Collect data (incremental or fresh)
      if @opts[:update]
        time = Utilities.get_modified_time("commit.json")
        collector.collect(@opts[:branch], "--since=\"#{time}\"")
      else
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
