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

    def binary?
      submodule? ? false : blob.binary?
    end

    def image?
      submodule? ? false : blob.binary?
    end

    def vendored?
      submodule? ? false : blob.vendored?
    end

    def generated?
      submodule? ? false : blob.generated?
    end

    def submodule?
      blob.kind_of? Grit::Submodule
    end

    def inspect
      %Q{<GitStatistics::FileStat @language=#{language} @additions=#{additions}, @deletions=#{deletions}, @net=#{net}>}
    end

    # Determine the language of the file from the blob
    def language
      if submodule?
        "Unknown"
      else
        (blob && blob.language && blob.language.name) || "Unknown"
      end
    end
  end
end
