#!/usr/bin/env rake

require 'rake/clean'
require 'rspec/core/rake_task'
require 'bundler/gem_tasks'
require 'rubocop/rake_task'

CLOBBER.include('coverage')

RuboCop::RakeTask.new

desc 'Run all specs'
RSpec::Core::RakeTask.new do |t|
  t.pattern = './spec/**/*spec.rb'
end

desc 'Run git_statistics on current/specified directory (for debugging)'
task :run, :dir do |t, args|
  Bundler.require(:debug)
  require 'git_statistics'
  GitStatistics::CLI.new(args[:dir]).execute
end

task default: :spec
