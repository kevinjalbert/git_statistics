require 'logger'
require 'singleton'

module GitStatistics
  class Log
    include Singleton

    attr_accessor :logger, :base_directory, :debugging

    def initialize
      @base_directory = File.expand_path('../..', __FILE__) + '/'
      @debugging = false
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::ERROR
      @logger.formatter = proc do |sev, datetime, progname, msg|
        "#{msg}\n"
      end
    end

    def self.use_debug
      instance.debugging = true
      instance.logger.formatter = proc do |sev, datetime, progname, msg|
        "#{sev} [#{progname}]: #{msg}\n"
      end
    end

    # Determine the file, method, line number of the caller
    def self.parse_caller(message)
      if /^(?<file>.+?):(?<line>\d+)(?::in `(?<method>.*)')?/ =~ message
        file = Regexp.last_match[:file]
        line = Regexp.last_match[:line]
        method = Regexp.last_match[:method]
        "#{file.sub(instance.base_directory, '')}:#{line}"
      end
    end

    def self.method_missing(method, *args, &blk)
      if valid_method? method
        instance.logger.progname = parse_caller(caller(1).first) if instance.debugging
        instance.logger.send(method, *args, &blk)
      else
        super
      end
    end

    def self.respond_to_missing?(method, include_all = false)
      if valid_method? method
        true
      else
        super
      end
    end

    def self.valid_method?(method)
      instance.logger.respond_to? method
    end
  end
end
