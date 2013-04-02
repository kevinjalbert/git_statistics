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

    private

      def summarize_diffstat(what)
        diffstats.map(&what).inject(0, :+)
      end

      def diffstats
        stats.to_diffstat
      end

  end
end
