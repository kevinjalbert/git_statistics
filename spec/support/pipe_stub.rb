module GitStatistics
  class PipeStub < Pipe
    def initialize(file)
      @file = file
      @dir = fixture_path
    end

    def io
      Dir.chdir(fixture_path) do
        File.open(@file, 'r').readlines
      end
    end
  end
end
