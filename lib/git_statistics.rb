require 'git_statistics/initialize'

module GitStatistics
  class GitStatistics
    def initialize(args=nil)
      @opts = Trollop::options do
        opt :email, "Use author's email instead of name", :default => false
        opt :merges, "Factor in merges when calculating statistics", :default => false
        opt :save, "Save the commits as commits.json", :default => false
        opt :pretty, "Save the commits as commits.json in pretty print (larger file size)", :default => false
        opt :load, "Load commits.json instead of re-collecting data", :default => false
        opt :update, "Update commits.json with new data (same as save and load together)", :default => false
        opt :sort, "Sort authors by {commits, additions, deletions, create, delete, rename, copy, merges}", :default => "commits"
        opt :top, "Show the top N authors in results", :default => 0
        opt :branch, "Use current branch for statistics (otherwise all branches)", :default => false
        opt :verbose, "Verbose output (shows progress)", :default => false
      end
    end

    def execute
      collector = Collector.new(@opts[:verbose])

      # Collect commit data
      if @opts[:load] || @opts[:update]
        collector.commits.load("commits.json")
      else
        collector.collect(@opts[:branch])
      end

      # Collect incremental recent data
      if @opts[:update]
        time = get_modified_time("commit.json")
        collector.collect(@opts[:branch], "--since=\"#{time}\"")
      end

      # Save data
      if @opts[:save] || @opts[:update] || @opts[:pretty]
        collector.commits.save("commits.json", @opts[:pretty])
      end

      collector.commits.calculate_statistics(@opts[:email], @opts[:merges])

      collector.print_summary(@opts[:sort].to_sym, @opts[:email], @opts[:top])
    end

    def get_modified_time(file)
      if OS.mac?
        Time.at(`stat -f %m commits.json`.to_i)
      elsif OS.linux?
        Time.at(`stat -c %Y commits.json`.to_i)
      else
        raise "Update on the Windows operating system is not supported"
      end
    end
  end
end
