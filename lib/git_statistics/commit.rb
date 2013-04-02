require 'delegate'

module GitStatistics
  class Commit < SimpleDelegator
    def initialize(commit)
      super(commit)
    end

    def merge?
      parents.size > 1
    end
  end
end
