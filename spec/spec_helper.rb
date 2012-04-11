require 'simplecov'

SimpleCov.start do
  add_filter "/spec/"
end

require File.dirname(__FILE__) + '/../lib/initialize.rb'

def fixture(file)
  File.new(File.dirname(__FILE__) + '/fixtures/' + file, 'r')
end

