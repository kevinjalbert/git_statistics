module Logging

  # Return the logger for the calling class/module
  def logger
    if self.kind_of?(Class)
      @logger ||= Logging.logger_for(self.class.name)
    else
      @logger ||= Logging.logger_for(self)
    end
  end

  # Adjust the log level of all further created loggers.
  # Use as soon as possible as it does not adjust already existing loggers.
  def global_logger_level (level)
    @@level = level
  end

  # Use a hash class-ivar to cache a unique Logger per class:
  @loggers = {}

  # Default log level for all loggers
  @@level = Logger::UNKNOWN

  class << self
    def logger_for(name)
       @loggers[name] ||= configure_logger_for(name)
    end

    def configure_logger_for(name)
      logger = Logger.new(STDOUT)
      logger.progname = name
      logger.sev_threshold = @@level
      logger
    end
  end
end
