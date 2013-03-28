$:.unshift File.expand_path("../../lib", __FILE__)
begin
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec/"
  end
rescue LoadError
end

FIXTURE_PATH = Pathname.new(Dir.pwd) + "spec" + "fixtures"

require 'git_statistics/initialize'

Dir.glob(File.dirname(__FILE__) + '/support/**/*.rb') {|file| require file}

def fixture(file)
  GitStatistics::PipeStub.new(file)
end

def setup_commits(commits, file_load, file_save, pretty)
  Dir.chdir(FIXTURE_PATH) do
    return if file_load.nil? || file_save.nil?
    commits.load(File.new(file_load, 'r'))
    commits.save(file_save, pretty)
  end
end
