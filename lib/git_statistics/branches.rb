module GitStatistics
  class Branches
    def self.all
      list.collect { |branch| branch.sub(/\A\*\s/, "") }
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
