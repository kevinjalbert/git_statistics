require 'rake/clean'
require 'rspec/core/rake_task'

CLOBBER.include('coverage')

desc "Run all specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = "./test/spec/**/*spec.rb"
end

task :default => :spec
