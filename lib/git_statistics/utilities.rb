require 'rbconfig'

module GitStatistics
  module Utilities

    class NotInRepository < StandardError; end

    def self.get_repository(path = Dir.pwd)
      ascender = Pathname.new(path).to_enum(:ascend)
      repo_path = ascender.detect { |path| (path + '.git').exist? }
      raise NotInRepository unless repo_path
      Grit::Repo.new(repo_path.to_s)
    rescue NotInRepository
      Log.error "You must be within a Git project to run git-statistics."
      exit 0
    end

    def self.max_length_in_list(list, max = nil)
      return nil if list.nil?
      list.each do |key,value|
        max = key.length if max.nil? || key.length > max
      end
      max
    end

    def self.split_old_new_file(old, new)
      # Split the old and new chunks up (separted by the =>)
      split_old = old.split('{')
      split_new = new.split('}')

      # Handle recombine the file splits into their whole paths)
      if split_old.one? && split_new.one?
        old_file = split_old[0]
        new_file = split_new[0]
      elsif split_new.one?
        old_file = split_old[0] + split_old[1]
        new_file = split_old[0] + split_new[0]
      elsif split_old.one?
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

    def self.get_modified_time(file)
      if os == :windows
        raise "`stat` is not supported on the Windows operating system"
      end
      flags = os == :mac ? "-f %m" : "-c %Y"
      time_at("stat #{flags} #{file}")
    end

    def os
      case RbConfig::CONFIG['host_os']
      when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
        :windows
      when /darwin|mac os/
        :mac
      when /linux/
        :linux
      when /solaris|bsd/
        :unix
      else
        :unknown
      end
    end

    def self.time_at(cmd)
      Time.at(%x{#{cmd}}.to_i)
    end

    def self.number_of_matching_files(directory, pattern)
      Dir.entries(directory).grep(pattern).size
    rescue SystemCallError
      warn "No such directory #{File.expand_path(directory)}"
      0
    end
  end
end
