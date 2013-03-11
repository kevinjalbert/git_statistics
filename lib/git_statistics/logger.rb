module Logging
  # Use a hash to cache a unique logger per class/module
  @loggers = {}

  # The global/default logging level
  @@level = Logger::UNKNOWN

  # Adjust the log level of created loggers, and future created loggers
  def set_global_logger_level (level)
    @@level = level
    self.logger.sev_threshold = level
    Logging.update_loggers
  end

  # Return the logger for the calling class/module
  def logger
    if self.is_a? Module
      @logger ||= Logging.logger_for(self)
    else
      @logger ||= Logging.logger_for(self.class.name)
    end
  end

  class << self
    # Updates all existing loggers to match the global logging level
    def update_loggers
      @loggers.each do |name, logger|
        logger.sev_threshold = @@level
      end
    end

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
