require 'language_sniffer'
module Grit
  class Blob
    include LanguageSniffer::BlobHelper
  end
end
