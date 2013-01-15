module GitStatistics
  class CommitLineExtractor

    RENAMED_OR_COPIED       = /^(rename|copy)\s+(.+)\s+=>\s+(.+)\s+\((\d+)/i
    CREATED_OR_DELETED      = /^(create|delete) mode \d+ ([^\\\n]*)/i
    MODIFIED_OR_RENAMED     = /^([-|\d]+)\s+([-|\d]+)\s+(.+)\s+=>\s+(.+)/i
    ADDITIONS_OR_DELETIONS  = /^([-|\d]+)\s+([-|\d]+)\s+(.+)/i

    attr_reader :line

    def initialize(line)
      @line = line
    end

    def changed
      changes = line.scan(MODIFIED_OR_RENAMED).first
      changes = changes_are_right_size(changes, 4) do |changes|
        split_file = Utilities.split_old_new_file(changes[2], changes[3])
        {:additions => changes[0].to_i,
          :deletions => changes[1].to_i,
          :file => Utilities.clean_string(split_file[:new_file]),
          :old_file => Utilities.clean_string(split_file[:old_file])}
      end
      return changes unless changes.nil?

      changes = line.scan(ADDITIONS_OR_DELETIONS).first
      changes_are_right_size(changes, 3) do |changes|
        {:additions => changes[0].to_i,
          :deletions => changes[1].to_i,
          :file => Utilities.clean_string(changes[2])}
      end
    end

    def created_or_deleted
      changes = line.scan(CREATED_OR_DELETED).first
      changes_are_right_size(changes, 2) do |changes|
        {:status => Utilities.clean_string(changes[0]),
          :file => Utilities.clean_string(changes[1])}
      end
    end

    def renamed_or_copied
      changes = line.scan(RENAMED_OR_COPIED).first
      changes_are_right_size(changes, 4) do |changes|
        split_file = Utilities.split_old_new_file(changes[1], changes[2])
        {:status => Utilities.clean_string(changes[0]),
          :old_file => Utilities.clean_string(split_file[:old_file]),
          :new_file => Utilities.clean_string(split_file[:new_file]),
          :similar => changes[3].to_i}
      end
    end

    private

      def changes_are_right_size(changes, size = 4)
        if !changes.nil? && changes.size == size
          yield changes
        else
          nil
        end
      end

  end
end
