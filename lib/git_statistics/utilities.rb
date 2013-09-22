require 'rbconfig'

module GitStatistics
  module Utilities

    def self.max_length_in_list(list, max = nil)
      return nil if list.nil?
      list.each do |key,value|
        max = key.length if max.nil? || key.length > max
      end
      max
    end

    def self.get_modified_time(file)
      if os == :windows
        raise "`stat` is not supported on the Windows operating system"
      end
      flags = os == :mac ? "-f %m" : "-c %Y"
      time_at("stat #{flags} #{file}")
    end

    def self.os
      case RbConfig::CONFIG['host_os']
      when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
        :windows
      when /darwin|mac os/
        :mac
      when /linux/
        :linux
      when /solaris|bsd/
        :unix
      else
        :unknown
      end
    end

    def self.time_at(cmd)
      Time.at(%x{#{cmd}}.to_i)
    end

    def self.number_of_matching_files(directory, pattern)
      Dir.entries(directory).grep(pattern).size
    rescue SystemCallError
      Log.error "No such directory #{File.expand_path(directory)}"
      0
    end
  end
end
