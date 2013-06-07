module GitStatistics
  class SplitFile
    attr_reader :old, :new

    def initialize(old_file, new_file)
      @old = old_file
      @new = new_file
    end

    def split
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

      SplitFile.new(old_file.gsub('//', '/'), new_file.gsub('//', '/'))
    end

    # For inline assignment
    def to_ary
      [old, new]
    end
  end
end
