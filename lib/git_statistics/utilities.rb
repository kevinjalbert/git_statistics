module GitStatistics
  module Utilities
    def self.get_repository(path=Dir.pwd)
      # Connect to git repository if it exists
      directory = Pathname.new(path)
      repo = nil
      while !directory.root? do
        begin
          repo = Grit::Repo.new(directory)
          return repo
        rescue
          directory = directory.parent
        end
      end
    end

    def self.clean_string(string)
      return string.strip.force_encoding("iso-8859-1").encode("utf-8")
    end

    def self.split_old_new_file(old, new)
      # Split the old and new chunks up (separted by the =>)
      split_old = old.split('{')
      split_new = new.split('}')

      # Handle recombine the file splits into their whole paths)
      if split_old.size == 1 && split_new.size == 1
        old_file = split_old[0]
        new_file = split_new[0]
      elsif split_new.size == 1
        old_file = split_old[0] + split_old[1]
        new_file = split_old[0] + split_new[0]
      elsif split_old.size == 1
        old_file = split_old[0] + split_new[1]
        new_file = split_old[0] + split_new[0] + split_new[1]
      else
        old_file = split_old[0] + split_old[1] + split_new[1]
        new_file = split_old[0] + split_new[0] + split_new[1]
      end

      # Return files, yet remove the '//' if present from combining splits
      return {:old_file => old_file.gsub('//', '/'),
              :new_file => new_file.gsub('//', '/')}
    end

    def self.find_blob_in_tree(tree, file)
      # Check If cannot find tree in commit or if we found a submodule as the changed file
      if tree == nil
        return nil
      elsif file == nil
        return nil
      elsif tree.instance_of?(Grit::Submodule)
        return tree
      end

      # If the blob is within the current directory (tree)
      if file.size == 1
        blob = tree / file.first

        # Check if blob is nil (could not find changed file in tree)
        if blob == nil

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

