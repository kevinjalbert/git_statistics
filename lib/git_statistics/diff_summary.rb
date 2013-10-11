module GitStatistics
  class DiffSummary < SimpleDelegator
    def initialize(repo, patch)
      @repo = repo
      super(patch)
    end

    # We flip these around since we are diffing in the opposite direction -- new.diff(old)
    def additions
      __getobj__.deletions
    end

    # We flip these around since we are diffing in the opposite direction -- new.diff(old)
    def deletions
      __getobj__.additions
    end

    def net
      additions - deletions
    end

    # We flip these around since we are diffing in the opposite direction -- new.diff(old)
    def status
      if delta.status == :deleted
        return :added
      elsif delta.status == :added
        return :deleted
      else
        return delta.status
      end
    end

    def similarity
      delta.similarity
    end

    def filename
      if (status == :deleted)
        delta.old_file[:path]
      else
        delta.new_file[:path]
      end
    end

    # We flip these around since we are diffing in the opposite direction -- new.diff(old)
    def blob
      begin
        if (status == :deleted)
          blob = @repo.lookup(delta.new_file[:oid])  # Look at new instead of old
        else
          blob = @repo.lookup(delta.old_file[:oid])  # Look at old instead of new
        end
      rescue Rugged::OdbError
        Log.warn "Could not find object (most likely a submodule)"
        blob = nil
      end
    end

    def inspect
      %Q{<GitStatistics::FileStat @filename=#{filename} @status=#{status} @similarity=#{similarity} @language=#{language} @additions=#{additions}, @deletions=#{deletions}, @net=#{net}>}
    end

    def to_json
      { filename: filename, status: status, similarity: similarity, language: language, additions: additions, deletions: deletions, net: net}
    end

    # Determine the language of the file from the blob
    def language
      language = "Unknown"
      unless blob.nil?
        detected_language = LanguageSniffer.detect(filename, :content => blob.content).language
        unless detected_language.nil?
          language = detected_language.name
        end
      end
      language
    end
  end
end
