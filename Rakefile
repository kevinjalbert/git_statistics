#!/usr/bin/env rake

require 'rake/clean'
require 'rspec/core/rake_task'
require 'bundler/gem_tasks'
require 'tailor/rake_task'

CLOBBER.include('coverage')

Tailor::RakeTask.new

desc "Run all specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = "./spec/**/*spec.rb"
end

task :default => :spec
