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
      modified_or_renamed = line.scan(MODIFIED_OR_RENAMED).first
      modified_or_renamed = changes_are_right_size(modified_or_renamed, 4) do |changes|
        split_file = Utilities.split_old_new_file(changes[2], changes[3])
        {:additions => changes[0].to_i,
          :deletions => changes[1].to_i,
          :file => split_file[:new_file].clean_for_authors,
          :old_file => split_file[:old_file].clean_for_authors}
      end
      return modified_or_renamed unless modified_or_renamed.empty?

      addition_or_deletion = line.scan(ADDITIONS_OR_DELETIONS).first
      changes_are_right_size(addition_or_deletion, 3) do |changes|
        {:additions => changes[0].to_i,
          :deletions => changes[1].to_i,
          :file => changes[2].clean_for_authors}
      end
    end

    def created_or_deleted
      changes = line.scan(CREATED_OR_DELETED).first
      changes_are_right_size(changes, 2) do |changes|
        {:status => changes[0].clean_for_authors,
          :file => changes[1].clean_for_authors}
      end
    end

    def renamed_or_copied
      changes = line.scan(RENAMED_OR_COPIED).first
      changes_are_right_size(changes, 4) do |changes|
        split_file = Utilities.split_old_new_file(changes[1], changes[2])
        {:status => changes[0].clean_for_authors,
          :old_file => split_file[:old_file].clean_for_authors,
          :new_file => split_file[:new_file].clean_for_authors,
          :similar => changes[3].to_i}
      end
    end

    private

      def changes_are_right_size(changes, size = 4)
        if !changes.nil? && changes.size == size
          yield changes
        else
          {}
        end
      end

  end
end
