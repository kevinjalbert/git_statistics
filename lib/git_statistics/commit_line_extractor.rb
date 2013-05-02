require 'git_statistics/regex_matcher'

module GitStatistics
  class CommitLineExtractor

    AdditionsOrDeletions  = RegexMatcher.new(/^([-|\d]+)\s+([-|\d]+)\s+(.+)/i, 3)
    RenamedOrCopied       = RegexMatcher.new(/^(rename|copy)\s+(.+)\s+=>\s+(.+)\s+\((\d+)/i, 4)
    CreatedOrDeleted      = RegexMatcher.new(/^(create|delete) mode \d+ ([^\\\n]*)/i, 2)
    ModifiedOrRenamed     = RegexMatcher.new(/^([-|\d]+)\s+([-|\d]+)\s+(.+)\s+=>\s+(.+)/i, 4)

    attr_reader :line

    def initialize(line)
      @line = line
    end

    def changed
      modified_or_renamed = ModifiedOrRenamed.if_matches(line) do |(additions, deletions, old_file, new_file)|
        split_file = Utilities.split_old_new_file(old_file, new_file)
        {:additions => additions.to_i,
          :deletions => deletions.to_i,
          :file => split_file[:new_file],
          :old_file => split_file[:old_file]}
      end
      return modified_or_renamed unless modified_or_renamed.empty?

      AdditionsOrDeletions.if_matches(line) do |(additions, deletions, file)|
        {:additions => additions.to_i,
          :deletions => deletions.to_i,
          :file => file}
      end
    end

    def created_or_deleted
      CreatedOrDeleted.if_matches(line) do |(status, file)|
        {:status => status, :file => file}
      end
    end

    def renamed_or_copied
      RenamedOrCopied.if_matches(line) do |(status, old_file, new_file, similar)|
        split_file = Utilities.split_old_new_file(old_file, new_file)
        {:status => status,
          :old_file => split_file[:old_file],
          :new_file => split_file[:new_file],
          :similar => similar.to_i}
      end
    end

  end
end
