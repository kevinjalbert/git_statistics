require 'delegate'

module GitStatistics
  class Commit < SimpleDelegator
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
    end

    def file_stats
      diffstats.map { |diff| FileStat.new(diff, current_tree) }
    end

    class FileStat < SimpleDelegator
      def initialize(diffstat, tree)
        super(diffstat)
        @tree = tree
      end

      # Get the blob from the current tree and filename/filepath
      def blob
        @tree / filename
      end

      def inspect
        %Q{<GitStatistics::Commit::FileStat @language=#{language} @additions=#{additions}, @deletions=#{deletions}, @net=#{net}>}
      end

      # Determine the language of the file from the blob
      def language
        (blob.language && blob.language.name) || "Unknown"
      end
    end

    class LanguageStat
      attr_reader :name
      attr_reader :additions
      attr_reader :deletions
      attr_reader :net

      def initialize(language, additions, deletions, net)
        @name = (language && language.name) || language || "Unknown"
        @additions = additions
        @deletions = deletions
        @net = net
      end
    end

    def languages
      langs = Hash.new { |k,v| k[v] = [] }

      diffstats.each do |diff|
        language = (current_tree / diff.filename).language
        stat = LanguageStat.new(language, diff.additions, diff.deletions, diff.net)
        langs[stat.name] << stat
      end

      langs.collect do |lang, stats|
        additions = stats.map(&:additions).inject(0, :+)
        deletions = stats.map(&:deletions).inject(0, :+)
        net       = stats.map(&:net).inject(0, :+)
        LanguageStat.new(OpenStruct.new(name: lang), additions, deletions, net)
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

      def commit_summary(what)
        file_stats.map(&what).inject(0, :+)
      end

      def diffstats
        @diffstats ||= stats.to_diffstat
      end

  end
end
