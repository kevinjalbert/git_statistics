module GitStatistics
  class PipeStub < Pipe
    def initialize(file)
      @file = file
    end

    def io
      Dir.chdir(fixture_path) do
        File.open(@file, 'r').readlines
      end
    end
  end
end
