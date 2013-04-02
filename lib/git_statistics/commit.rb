require 'delegate'

module GitStatistics
  class Commit < SimpleDelegator
    attr_reader :obj
    def initialize(commit)
      @obj = commit
      super(commit)
    end

    def merge?
      parents.size > 1
    end
  end
end
