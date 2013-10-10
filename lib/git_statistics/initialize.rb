require 'json'
require 'pathname'
require 'ostruct'
require 'optparse'
require 'delegate'
require 'fileutils'

require 'rugged'
require 'language_sniffer'

Dir.glob(File.dirname(__FILE__) + '/**/*.rb') { |file| require file }
