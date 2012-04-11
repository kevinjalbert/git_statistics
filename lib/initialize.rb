require 'ap'
require 'json'
require 'trollop'
Dir.glob(File.dirname(__FILE__) + '/git-statistics/*.rb') {|file| require file}
