module GitStatistics
  class FileStat < SimpleDelegator
    def initialize(diffstat, tree)
      super(diffstat)
      @tree = tree
    end

    # Get the blob from the current tree and filename/filepath
    def blob
      @tree / filename
    end

    def inspect
      %Q{<GitStatistics::FileStat @language=#{language} @additions=#{additions}, @deletions=#{deletions}, @net=#{net}>}
    end

    # Determine the language of the file from the blob
    def language
      (blob.language && blob.language.name) || "Unknown"
    end
  end
end
