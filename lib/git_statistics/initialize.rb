require 'json'
require 'grit'
require 'pathname'
require 'ostruct'
require 'optparse'

# Must be required before all other files
require 'git_statistics/blob'
require 'git_statistics/regex_matcher'

Dir.glob(File.dirname(__FILE__) + '/**/*.rb') {|file| require file}
