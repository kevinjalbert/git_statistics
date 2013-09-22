module GitStatistics
  module BlobFinder

    def self.get_blob(commit, file)
      # Split up file for Grit navigation
      file = file.split(File::Separator)

      # Acquire blob of the file for this specific commit
      blob = BlobFinder.find_blob_in_tree(commit.tree, file)

      # If we cannot find blob in current commit (deleted file), check previous commit
      if blob.nil? || blob.instance_of?(Grit::Tree)
        prev_commit = commit.parents.first
        return nil if prev_commit.nil?

        blob = BlobFinder.find_blob_in_tree(prev_commit.tree, file)
      end
      return blob
    end

    def self.find_blob_in_tree(tree, file)
      # Check If cannot find tree in commit or if we found a submodule as the changed file
      if tree.nil? || file.nil?
        return nil
      elsif tree.instance_of?(Grit::Submodule)
        return tree
      end

      # If the blob is within the current directory (tree)
      if file.one?
        blob = tree / file.first

        # Check if blob is nil (could not find changed file in tree)
        if blob.nil?

          # Try looking for submodules as they cannot be found using tree / file notation
          tree.contents.each do |content|
            if file.first == content.name
              return tree
            end
          end

          # Exit through recusion with the base case of a nil tree/blob
          return find_blob_in_tree(blob, file)
        end
        return blob
      else
        # Explore deeper in the tree to find the blob of the changed file
        return find_blob_in_tree(tree / file.first, file[1..-1])
      end
    end

  end
end
