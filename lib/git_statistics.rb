require 'git_statistics/initialize'

class GitStatistics

  def initialize(args=nil)
    @opts = Trollop::options do
      opt :email, "Use author's email instead of name", :default => false
      opt :merges, "Factor in merges when calculating statistics", :default => false
      opt :save, "Save the commits as commits.json", :default => false
      opt :pretty, "Pretty print saved commits (larger file size)", :default => false
      opt :load, "Load commits.json instead of re-collecting data", :default => false
      opt :update, "Update commits.json with new data (same as save and load together)", :default => false
      opt :sort, "Sort authors by {commits, insertions, deletions, creates, deletes, renames, copies, merges}", :default => "commits"
      opt :top, "Show the top N authors in results", :default => 0
      opt :branch, "Use current branch for statistics (otherwise all branches)", :default => false
    end
  end

  def execute
    collector = Collector.new

    # Collect commit data
    if @opts[:load] || @opts[:update]
      collector.commits.load("commits.json")
    else
      collector.collect(@opts[:branch])
    end

    # Collect incremental recent data
    if @opts[:update]
      collector.collect(@opts[:branch], "--since=\"`date -r commits.json \"+%F %T\"`\"")
    end

    # Save data
    if @opts[:save] || @opts[:update]
      collector.commits.save("commits.json", @opts[:pretty])
    end

    collector.commits.calculate_statistics(@opts[:email], @opts[:merges])

    collector.print_summary(@opts[:sort].to_sym, @opts[:email], @opts[:top])
  end
end
