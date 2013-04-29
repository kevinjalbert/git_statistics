module GitStatistics
  class Stats < Hash
    def sorted(&block)
      self.class[sort(&block)]
    end
  end
end
