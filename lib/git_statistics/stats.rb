module GitStatistics
  class Stats < Hash

    def sorted(&block)
      self.class[sort(&block)]
    end

    def sort_by(type)
      sorted { |a,b| b[1][type.to_sym] <=> a[1][type] }
    end

    def take_top(top_n = 0)
      top_n = 0 if top_n < 0
      self.class[*to_a[0..(top_n - 1)].flatten]
    end

  end
end
