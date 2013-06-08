require 'json'
require 'grit'
require 'pathname'
require 'ostruct'
require 'optparse'
require 'delegate'

# Must be required before all other files
require 'git_statistics/blob'

Dir.glob(File.dirname(__FILE__) + '/**/*.rb') {|file| require file}
