module GitStatistics
  class CommitSummary < SimpleDelegator
    def initialize(commit)
      super(commit)
    end

    # A Git commit is a merge if it has more than one parent
    def merge?
      parents.size > 1
    end

    # How many files were removed in this commit
    def removed_files
      show.select { |diff| diff.deleted_file == true }.count
    end

    # How many files were added in this commit
    def new_files
      show.select { |diff| diff.new_file == true }.count
    end

    # How many total additions in this commit?
    def additions
      commit_summary(:additions)
    end

    # How many total deletions in this commit?
    def deletions
      commit_summary(:deletions)
    end

    # What is the net # of lines changes in this commit?
    def net
      commit_summary(:net)
    end

    def file_stats
      diffstats.map { |diff| DiffSummary.new(diff, current_tree) }
    end

    LanguageStat = Struct.new(:name, :additions, :deletions, :net)

    # Array of LanguageStat objects (one for each language) for simple calculations
    def languages
      grouped_language_files.collect do |language, stats|
        additions = summarize(stats, :additions)
        deletions = summarize(stats, :deletions)
        net       = summarize(stats, :net)
        LanguageStat.new(language, additions, deletions, net)
      end
    end

    # Group file statistics by language
    def grouped_language_files
      file_stats.group_by(&:language)
    end

    # Files touched in this commit
    def files
      diffstats.map(&:filename)
    end

    # Fetch the current Grit::Repo tree from this commit
    def current_tree
      @current_tree ||= repo.tree(sha)
    end

    private

      def summarize(stats, what)
        stats.map(&what).inject(0, :+)
      end

      def commit_summary(what)
        summarize(file_stats, what)
      end

      def diffstats
        if merge?
          merge_diffstats
        else
          stats.to_diffstat
        end
      end

      # Hackery coming...
      DIFFSTAT_REGEX = /(\d+)\s+(\d+)\s+([._\/\\\w]+)\n?/i
      def merge_diffstats
        native_diff = repo.git.native(:diff, {numstat: true}, parents.join("..."))
        per_file_info = native_diff.scan(DIFFSTAT_REGEX)
        per_file_info.map { |add, del, file| Grit::DiffStat.new(file, add.to_i, del.to_i) }
      end

  end
end
