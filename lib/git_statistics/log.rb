require 'logger'
require 'singleton'

class Log
  include Singleton

  attr_accessor :logger, :base_directory

  def initialize
    @base_directory = File.expand_path("../..", __FILE__) + "/"
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::ERROR
    @logger.formatter = proc do |sev, datetime, progname, msg|
      "#{sev} [#{progname}]: #{msg}\n"
    end
  end

  # Determine the file, method, line number of the caller
  def self.parse_caller(message)
    if /^(?<file>.+?):(?<line>\d+)(?::in `(?<method>.*)')?/ =~ message
      file = Regexp.last_match[:file]
      line = Regexp.last_match[:line]
      method = Regexp.last_match[:method]
      "#{file.sub(instance.base_directory, "")}:#{line}"
    end
  end

  def self.method_missing(method, *args, &blk)
    if valid_method? method
      instance.logger.progname = parse_caller(caller(1).first)
      instance.logger.send(method, *args, &blk)
    else
      super
    end
  end

  def self.respond_to_missing?(method)
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