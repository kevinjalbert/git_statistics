# -*- encoding: utf-8 -*-
$:.unshift File.expand_path("../lib", __FILE__)
require 'git_statistics/version'

Gem::Specification.new do |gem|
  gem.homepage      = 'https://github.com/kevinjalbert/git_statistics'
  gem.authors       = ["Kevin Jalbert"]
  gem.email         = ["kevin.j.jalbert@gmail.com"]
  gem.name          = 'git_statistics'
  gem.version       = GitStatistics::VERSION
  gem.summary       = "Gem that provides the ability to gather detailed git statistics"
  gem.description   = "git_statistics is a gem that provides detailed git statistics"
  gem.require_paths = ["lib"]
  gem.files         = Dir['lib/**/*']
  gem.test_files    = Dir['spec/**/*_spec.rb']
  gem.executables   = %w[ git_statistics git-statistics ]
  gem.required_ruby_version = '>= 1.9.3'
end
