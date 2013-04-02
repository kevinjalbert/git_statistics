require 'delegate'

module GitStatistics
  class Commit < SimpleDelegator
    def initialize(commit)
      super(commit)
    end

    def merge?
      parents.size > 1
    end

    def removed_files
      show.select { |diff| diff.deleted_file == true }.count
    end

    def new_files
      show.select { |diff| diff.new_file == true }.count
    end

    %w[additions deletions net].each do |stats|
      define_method(stats) do
        summarize_diffstat(stats.to_sym)
      end
    end

    # All languages touched in this commit
    def languages
      blobs.map(&:language).map(&:name).uniq
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
