Gem::Specification.new do |gem|
  gem.name        = 'git_statistics'
  gem.version     = '0.1.0'
  gem.date        = '2012-04-11'
  gem.summary     = "Gem that provides the ability to gather detailed git statistics"
  gem.description = "git_statistics is a gem that provides detailed git statistics"
  gem.authors     = ["Kevin Jalbert"]
  gem.email       = 'kevin.j.jalbert@gmail.com'
  gem.files       = Dir.glob('lib/**/*.rb')
  gem.homepage    = 'https://github.com/kevinjalbert/git-statistics'
  gem.executables << 'git_statistics'
  gem.add_dependency('json')
  gem.add_dependency('trollop')
end
