module GitStatistics
  class Branches

    CURRENT_BRANCH = /\A\*\s/

    def self.all
      list.collect { |branch| branch.sub(CURRENT_BRANCH, "") }
    end

    def self.current
      result = list.detect { |branch| branch =~ CURRENT_BRANCH } || '(none)'
      result.sub(CURRENT_BRANCH, "")
    end

    private

      def self.list
        pipe.map(&:strip).reject { |b| b =~ /no branch/i }
      end

      def self.pipe
        Pipe.new("git --no-pager branch --no-color")
      end
  end
end
