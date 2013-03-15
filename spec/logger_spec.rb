require 'spec_helper'

include GitStatistics

describe Logger do

  let(:test_module) do
    Module.new{ extend Logging }
  end

  let(:test_class) do
    Class.new{ include Logging }.new
  end

  let(:concret_test_class) do
    class ConcretTestClass
      include Logging
    end.new
  end

  let(:concret_test_module) do
    module ConcretTestModule
      extend Logging
    end
  end

  context "for class" do
    context "initializes correctly" do
      context "one class" do
        it {
          test_class.should_not be_a Module
          test_class.logger.sev_threshold.should equal(Logger::UNKNOWN)
        }
      end

      context "multiple classes" do
        it {
          # Make sure classes are not the same
          concret_test_class.class.should_not equal(test_class.class)

          # Ensure loggers between classes are different
          concret_test_class.logger.should_not equal(test_class.logger)
        }
      end

      context "multiple instances of same class" do
        it {
          # Create a new instance of the ConcretTestClass
          new_class = ConcretTestClass.new

          # Make sure classes are the same, yet different instance
          new_class.should_not equal(concret_test_class)
          new_class.class.should equal(concret_test_class.class)

          # Ensure loggers between classes are the same
          new_class.logger.should equal(concret_test_class.logger)
        }
      end
    end

    context "change logger level" do
      context "once" do
        it {
          test_class.logger.sev_threshold = Logger::INFO
          test_class.logger.sev_threshold.should equal(Logger::INFO)
        }
      end

      context "multiple times" do
        it {
          test_class.logger.sev_threshold = Logger::INFO
          test_class.logger.sev_threshold.should equal(Logger::INFO)
          test_class.logger.sev_threshold = Logger::DEBUG
          test_class.logger.sev_threshold.should equal(Logger::DEBUG)
        }
      end
    end

    context "change global logger level" do
      after {test_class.set_global_logger_level(Logger::UNKNOWN)}

      context "current logger object updates" do
        it {
          test_class.set_global_logger_level(Logger::INFO)
          test_class.logger.sev_threshold.should equal(Logger::INFO)
        }
      end

      context "effect new loggers" do
        it {
          test_class.set_global_logger_level(Logger::INFO)
          concret_test_class.logger.sev_threshold.should equal(Logger::INFO)
        }
      end
    end

  end

  context "for module" do
    context "initializes correctly" do
      context "one module" do
        it {
          test_module.should be_a Module
          test_module.logger.sev_threshold.should equal(Logger::UNKNOWN)
        }
      end

      context "multiple modules" do
        it {
          # Make sure modules are not the same
          test_module.should_not equal(concret_test_module)

          # Ensure loggers between modules are different
          test_module.logger.should_not equal(concret_test_module.logger)
        }
      end
    end

    context "change logger level" do
      context "once" do
        it {
          test_module.logger.sev_threshold = Logger::INFO
          test_module.logger.sev_threshold.should equal(Logger::INFO)
        }
      end

      context "multiple times" do
        it {
          test_module.logger.sev_threshold = Logger::INFO
          test_module.logger.sev_threshold.should equal(Logger::INFO)
          test_module.logger.sev_threshold = Logger::DEBUG
          test_module.logger.sev_threshold.should equal(Logger::DEBUG)
        }
      end
    end

    context "change global logger level" do
      after {test_module.set_global_logger_level(Logger::UNKNOWN)}

      context "current logger updates" do
        it {
          test_module.set_global_logger_level(Logger::INFO)
          test_module.logger.sev_threshold.should equal(Logger::INFO)
        }
      end

      context "effect new loggers" do
        it {
          test_module.set_global_logger_level(Logger::INFO)

          new_module = concret_test_module
          new_module.extend(Logging)

          new_module.logger.sev_threshold.should equal(Logger::INFO)
        }
      end
    end
  end

end
