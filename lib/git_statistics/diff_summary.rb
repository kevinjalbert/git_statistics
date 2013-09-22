module GitStatistics
  class DiffSummary < SimpleDelegator
    def initialize(diffstat, tree)
      super(diffstat)
      @tree = tree
    end

    # Get the blob from the current tree and filename/filepath
    def blob
      @tree / filename
    end

    def submodule?
      blob.kind_of? Grit::Submodule
    end

    def tree?
      blob.kind_of? Grit::Tree
    end

    def inspect
      %Q{<GitStatistics::FileStat @filename=#{filename} @language=#{language} @additions=#{additions}, @deletions=#{deletions}, @net=#{net}>}
    end

    # Determine the language of the file from the blob
    def language
      if tree?
        "Unknown"
      elsif submodule?
        "Submodule"
      else
        (blob && blob.language && blob.language.name) || "Unknown"
      end
    end
  end
end
