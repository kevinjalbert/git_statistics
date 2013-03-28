module GitStatistics
  class PipeStub < Pipe

    def initialize(file)
      @file = file
    end

    def io
      file.readlines
    end

    def file
      @opened = File.open(filepath)
    end

    def filepath
      FIXTURE_PATH + @file
    end
  end
end
