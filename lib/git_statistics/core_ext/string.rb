module GitStatistics
  module StringExt
    def clean_for_authors
      self.strip.force_encoding("iso-8859-1").encode("utf-8")
    end
  end
end

class String
  include GitStatistics::StringExt
end
