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

    %w[additions deletions net].each do |stats|
      define_method(stats) do
        summarize_diffstat(stats.to_sym)
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
    end

    # Blobs pulled from the files of this commit
    def blobs
      files.collect do |filepath|
        current_tree / filepath
      end
    end

    # Files that changed in this commit
    def files
      diffstats.map(&:filename)
    end

    def current_tree
      @current_tree ||= repo.tree(sha)
    end

    private

      def summarize_diffstat(what)
        diffstats.map(&what).inject(0, :+)
      end

      def diffstats
        stats.to_diffstat
      end

  end
end
