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
      modified_or_renamed = ModifiedOrRenamed.if_matches(line) do |changes|
        split_file = Utilities.split_old_new_file(changes[2], changes[3])
        {:additions => changes[0].to_i,
          :deletions => changes[1].to_i,
          :file => split_file[:new_file],
          :old_file => split_file[:old_file]}
      end
      return modified_or_renamed unless modified_or_renamed.empty?

      AdditionsOrDeletions.if_matches(line) do |changes|
        {:additions => changes[0].to_i,
          :deletions => changes[1].to_i,
          :file => changes[2]}
      end
    end

    def created_or_deleted
      CreatedOrDeleted.if_matches(line) do |changes|
        {:status => changes[0],
          :file => changes[1]}
      end
    end

    def renamed_or_copied
      RenamedOrCopied.if_matches(line) do |changes|
        split_file = Utilities.split_old_new_file(changes[1], changes[2])
        {:status => changes[0],
          :old_file => split_file[:old_file],
          :new_file => split_file[:new_file],
          :similar => changes[3].to_i}
      end
    end

  end
end
