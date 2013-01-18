module GitStatistics
  class RegexMatcher

    attr_reader :regex, :expected_change_count
    def initialize(regex, expected_change_count)
      @regex = regex
      @expected_change_count = expected_change_count
    end

    def scan(line)
      line.scan(regex).first || []
    end

    def if_matches(line)
      changes = self.scan(line)
      if changes && changes.size == expected_change_count
        yield changes
      else
        {}
      end
    end
  end
end
