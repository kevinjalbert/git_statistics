require 'delegate'

module GitStatistics
  class Commit < SimpleDelegator
    def initialize(commit)
      super(commit)
    end

    def merge?
      parents.size > 1
    end

    def additions
      summarize_diffstat(:additions)
    end

    def deletions
      summarize_diffstat(:deletions)
    end

    def net
      summarize_diffstat(:net)
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
