require 'rbconfig'

module GitStatistics
  module Utilities

    def self.max_length_in_list(list, min_length = nil)
      list ||= []
      min_length = min_length.to_i
      list_max = list.map { |k,_| k.length }.max || 0
      list_max >= min_length ? list_max : min_length
    end

    COMMANDS = {
      :windows => ->{ raise "`stat` is not supported on Windows" },
      :mac =>     ->{ "-f %m" }
    }
    COMMANDS.default = ->{ "-c %Y" }

    def self.get_modified_time(file)
      flags = COMMANDS[os].()
      time_at("stat #{flags} #{file}")
    end

    class OperatingSystem
      OPERATING_SYSTEMS = {
        /mswin|msys|mingw|cygwin|bccwin|wince|emc/ => :windows,
        /darwin|mac os/ => :mac,
        /linux/ => :linux,
        /solaris|bsd/ => :unix
      }
      OPERATING_SYSTEMS.default = :unknown

      def determine(os_name)
        OPERATING_SYSTEMS.select { |k,_| k =~ os_name }.first
      end
    end

    def self.time_at(cmd)
      Time.at(%x{#{cmd}}.to_i)
    end

    def self.os
      OperatingSystem.determine(RbConfig::CONFIG['host_os'])
    end

    def self.number_of_matching_files(directory, pattern)
      Dir.entries(directory).grep(pattern).size
    rescue SystemCallError
      Log.error "No such directory #{File.expand_path(directory)}"
      0
    end

  end
end
