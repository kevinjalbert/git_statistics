require 'simplecov'

SimpleCov.start do
  add_filter "/spec/"
end

require File.dirname(__FILE__) + '/../lib/git_statistics/initialize.rb'

def fixture(file)
  File.new(File.dirname(__FILE__) + '/fixtures/' + file, 'r')
end

def setup_commits(commits, file_load, file_save, pretty)
  return if file_load == nil || file_save == nil
  commits.load(fixture(file_load))
  commits.save(file_save, pretty)
end
