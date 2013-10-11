module GitStatistics
  class CommitSummary < SimpleDelegator
    def initialize(repo, commit)
      super(commit)
      @repo = repo
      @diff = diff(commit.parents.first)
      @patches = @diff.patches
    end

    # A Git commit is a merge if it has more than one parent
    def merge?
      parents.size > 1
    end

    # How many files were removed in this commit
    def deleted_files
      file_stats.select { |file| file.status == :deleted }.count
    end

    # How many files were added in this commit
    def added_files
      file_stats.select { |file| file.status == :added }.count
    end

    # How many files were modified (not added/deleted) in this commit
    def modified_files
      file_stats.select { |file| file.status == :modified }.count
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
      @cached_file_stats ||= diffstats.map { |diff| DiffSummary.new(@repo, diff) }
    end

    LanguageSummary = Struct.new(:name, :additions, :deletions, :net, :added_files, :deleted_files, :modified_files)

    # Array of LanguageSummary objects (one for each language) for simple calculations
    def languages
      grouped_language_files.collect do |language, stats|
        additions = summarize(stats, :additions)
        deletions = summarize(stats, :deletions)
        net       = summarize(stats, :net)
        LanguageSummary.new(language, additions, deletions, net, added_files, deleted_files, modified_files)
      end
    end

    # Group file statistics by language
    def grouped_language_files
      file_stats.group_by(&:language)
    end

    # Files touched in this commit
    def filenames
      file_stats.map(&:filename)
    end

    private

      def summarize(stats, what)
        stats.map(&what).inject(0, :+)
      end

      def commit_summary(what)
        summarize(file_stats, what)
      end

      def diffstats
        @patches
      end

  end
end
