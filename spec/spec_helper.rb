$:.unshift File.expand_path("../../lib", __FILE__)
begin
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec/"
  end
rescue LoadError
end

require 'git_statistics/initialize'

def fixture(file)
  File.new(File.dirname(__FILE__) + '/fixtures/' + file, 'r')
end

def setup_commits(commits, file_load, file_save, pretty)
  return if file_load.nil? || file_save.nil?
  commits.load(fixture(file_load))
  commits.save(file_save, pretty)
end
