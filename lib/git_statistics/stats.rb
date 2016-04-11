module GitStatistics
  class Stats < Hash

    def initialize(values = {})
      super()
      values.each { |k,v| self[k] = v}
    end

    def sorted(&block)
      self.class[sort(&block)]
    end

    def sort_by(type)
      sorted { |a,b| b[1][type.to_sym] <=> a[1][type] }
    end

    def take_top(top_n = 0)
      top_n = self.size if top_n.nil? || top_n <= 0
      self.class[to_a.take(top_n)]
    end

  end
end
