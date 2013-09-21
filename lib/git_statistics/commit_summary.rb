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
      cached_show.select { |diff| diff.deleted_file == true }.count
    end

    # How many files were added in this commit
    def new_files
      cached_show.select { |diff| diff.new_file == true }.count
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
      @cached_file_stats ||= diffstats.map { |diff| DiffSummary.new(diff, current_tree) }
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

    def cached_show
      @cached_commit_show ||= show
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
        filestatus = :modified
        language = stats.language

        # Determine if this file could be a new or deleted file
        if (stats.additions > 0 && stats.deletions == 0) || (stats.additions == 0 && stats.deletions > 0)
          # Extract file status from commit's diff object
          cached_show.each do |diff|
            if stats.filename == diff.b_path
              filestatus = :create if diff.new_file
              filestatus = :delete if diff.deleted_file
              break
            end
          end
        end

        # Determine language of blob
        if stats.tree?
          # Trees have no language (the tree's blobs are still processed via the remainder diffstats)
          language = "Unknown"
        elsif stats.submodule?
          language = "Submodule"
        elsif stats.blob.nil?
          # If blob is nil (i.e., deleted file) grab the previous version of this blob using the parents of the current commit
          blob = Utilities.get_blob(self.parents.first, stats.filename)
          blob = Utilities.get_blob(self.parents.last, stats.filename) if blob.nil?

          # Determine language of newly found blob
          if blob.kind_of? Grit::Tree
            language = "Unknown"
          elsif blob.kind_of? Grit::Submodule
            language = "Submodule"
          elsif blob.nil? || blob.language.nil?
            language = "Unknown"
          else
            language = blob.language.to_s
          end
        end

        # TODO Converts file summary into hash to keep json compatibility (for now)
        Hash[FileSummary.new(stats.filename, language, stats.additions, stats.deletions, stats.net, filestatus).each_pair.to_a]
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
