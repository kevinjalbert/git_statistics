module GitStatistics
  class RegexMatcher < Struct.new(:regex, :expected_change_count)
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
