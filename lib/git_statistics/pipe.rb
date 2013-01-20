module GitStatistics
  class Pipe
    include Enumerable

    attr_reader :command, :io
    def initialize(command)
      command.gsub!(/^\|/i, '')
      @command  = command
      @io       = open("|#{command}")
    end

    def each(&block)
      lines.each(&block)
    end

    def lines
      @io.map(&:clean_for_authors)
    end
  end
end
