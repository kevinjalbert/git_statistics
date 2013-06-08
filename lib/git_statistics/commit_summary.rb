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

    LanguageSummary = Struct.new(:name, :additions, :deletions, :net)

    # Array of LanguageSummary objects (one for each language) for simple calculations
    def languages
      grouped_language_files.collect do |language, stats|
        additions = summarize(stats, :additions)
        deletions = summarize(stats, :deletions)
        net       = summarize(stats, :net)
        LanguageSummary.new(language, additions, deletions, net)
      end
    end

    # Group file statistics by language
    def grouped_language_files
      file_stats.group_by(&:language)
    end

    FileSummary = Struct.new(:name, :language, :additions, :deletions, :net, :filestatus)

    # Array of FileSummary objects (one for each file) for simple calculations
    def files
      file_stats.collect{ |stats| determine_file_summary(stats) }
    end

    # Files touched in this commit
    def file_names
      diffstats.map(&:filename)
    end

    # Fetch the current Grit::Repo tree from this commit
    def current_tree
      @current_tree ||= repo.tree(sha)
    end

    private

      def determine_file_summary(stats)
        # Extract file status from commit's diff object
        filestatus = :modified
        show.each do |diff|
          if stats.filename == diff.b_path
            filestatus = :create if diff.new_file
            filestatus = :delete if diff.deleted_file
            break
          end
        end

        # If blob is nil (i.e., deleted file) grab the previous version of this file for the language
        if stats.blob.nil?
          # Try to find a valid blob using the parents of the current commit
          blob = Utilities.get_blob(self.parents.first, stats.filename)
          blob = Utilities.get_blob(self.parents.last, stats.filename) if blob.nil?

          # Special handling of blob (could be nil, submodule, unknown language)
          if blob.nil? || blob.kind_of?(Grit::Submodule) || blob.language.nil?
            language = "Unknown"
          else
            language = blob.language
          end
        else
          language = stats.language
        end

        # TODO Converts file summary into hash to keep json compatibility (for now)
        Hash[FileSummary.new(stats.filename, language.to_s, stats.additions, stats.deletions, stats.net, filestatus).each_pair.to_a]
      end

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
      DIFFSTAT_REGEX = /([-|\d]+)\s+([-|\d]+)\s+(.+)/i
      def merge_diffstats
        native_diff = repo.git.native(:diff, {numstat: true}, parents.join("..."))
        per_file_info = native_diff.scan(DIFFSTAT_REGEX)
        per_file_info.map { |add, del, file| Grit::DiffStat.new(file, add.to_i, del.to_i) }
      end

  end
end
