module GitStatistics
  class Branches

    CURRENT_BRANCH = /\A\*\s/

    def self.all
      list.collect { |branch| branch.sub(CURRENT_BRANCH, "") }
    end

    def self.current
      return '(none)' if detached?
      list.detect { |branch| branch =~ CURRENT_BRANCH }.sub(CURRENT_BRANCH, "")
    end

    def self.detached?
      stripped.any? { |branch| branch =~ /no branch/i }
    end

    private

      def self.list
        stripped.reject { |b| b =~ /no branch/i }
      end

      def self.stripped
        pipe.map(&:strip)
      end

      def self.pipe
        Pipe.new("git --no-pager branch --no-color")
      end

  end
end
