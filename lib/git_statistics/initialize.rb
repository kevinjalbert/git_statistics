require 'json'
require 'pathname'
require 'ostruct'
require 'optparse'

require 'grit'
require 'language_sniffer'

module Grit
  class Blob
    include ::LanguageSniffer::BlobHelper
  end
end

# Must be required before all other files
require 'git_statistics/regex_matcher'

Dir.glob(File.dirname(__FILE__) + '/**/*.rb') {|file| require file}
