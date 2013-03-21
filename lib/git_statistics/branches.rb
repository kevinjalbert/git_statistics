module GitStatistics
  class Branches
    def self.collect
      pipe.collect do |branch|
        branch.clean_for_authors.sub(/\A\*\s/, "")
      end.reject { |b| b == '(no branch)' }
    end

    private

    def self.pipe
      Pipe.new("git --no-pager branch --no-color")
    end
  end
end
