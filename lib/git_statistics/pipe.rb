module GitStatistics
  class Pipe
    include Enumerable

    def initialize(command)
      @command  = command
    end

    def command
      @command.dup.gsub(/\A\|/i, '')
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
      open("|#{command} 2>/dev/null")
    end
  end
end
