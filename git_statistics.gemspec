# -*- encoding: utf-8 -*-
require File.expand_path('../lib/git_statistics/version', __FILE__)

Gem::Specification.new do |gem|
  gem.homepage      = 'https://github.com/kevinjalbert/git_statistics'
  gem.authors       = ["Kevin Jalbert"]
  gem.email         = ["kevin.j.jalbert@gmail.com"]
  gem.name          = 'git_statistics'
  gem.version       = GitStatistics::VERSION
  gem.summary       = "Gem that provides the ability to gather detailed git statistics"
  gem.description   = "git_statistics is a gem that provides detailed git statistics"
  gem.require_paths = ["lib"]
  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.executables   = %w[ git_statistics git-statistics ]
  gem.required_ruby_version = '>= 1.9.1'
  gem.add_dependency('json')
  gem.add_dependency('trollop')
  gem.add_dependency('grit')
  gem.add_dependency('github-linguist')
  gem.add_dependency('os')
end
