require 'json'
require 'trollop'
require 'grit'
require 'linguist'
require 'os'
require 'pathname'

require 'git_statistics/core_ext/string'

# Custom Blob for Grit to enable Linguist
# This must load before other modules
module Grit
  class Blob
    include Linguist::BlobHelper
  end
end

Dir.glob(File.dirname(__FILE__) + '/*.rb') {|file| require file}
