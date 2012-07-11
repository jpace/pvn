#!/usr/bin/ruby -w
# -*- ruby -*-

require 'system/command/line'
require 'system/command/cachefile'

module System
  class CachingCommandLine < CommandLine
    # caches its input and values.
    @@cache_dir = '/tmp' + Pathname.new($0).expand_path

    class << self
      def cache_dir
        @@cache_dir
      end

      def cache_dir= dir
        @@cache_dir = dir
      end
    end

    def cache_dir
      @@cache_dir
    end

    def cache_file
      pwd = Pathname.pwd.split_path.join('')
      CacheFile.new cache_dir, @args
    end

    def execute
      cachefile = cache_file
      @output = cachefile.readlines
    end
  end
end
