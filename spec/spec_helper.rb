$:.unshift File.expand_path("../../lib", __FILE__)

require 'coveralls'
Coveralls.wear!

require 'pathname'
require 'tmpdir'

home_dir = Pathname.new(Dir.pwd)
spec_dir = home_dir + "spec"

FIXTURE_PATH = spec_dir + "fixtures"

Dir.glob(spec_dir + 'support/**/*.rb') {|file| require file}

require 'git_statistics/initialize'

GIT_REPO = GitStatistics::Repo.new(home_dir)

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

RSpec.configure do |config|
  config.before do
    %w[debug info warn error fatal].each do |level|
      GitStatistics::Log.stub(level)
    end
  end
end
