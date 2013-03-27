module GitStatistics
  class PipeStub < Pipe
    def initialize(file)
      @file = file
    end

    def io
      Dir.chdir(FIXTURE_PATH) do
        File.open(@file, 'r').readlines
      end
    end
  end
end
