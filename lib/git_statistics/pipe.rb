module GitStatistics
  class Pipe
    include Enumerable

    attr_reader :command
    def initialize(command)
      command.gsub!(/^\|/i, '')
      @command  = command
    end

    def each(&block)
      lines.each(&block)
    end

    def empty?
      lines.empty?
    end

    def lines
      io.map(&:clean_for_authors)
    end

    def io
      open("|#{command}")
    end
  end
end
