#!/usr/bin/ruby -w
# -*- ruby -*-

require 'riel'
require 'rubygems'
require 'system/command/line'
require 'system/command/cachefile'

module PVN
  module System
    class CachingCommandLine < CommandLine
      # caches its input and values.
      @@cache_dir = nil

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
        info "pwd: #{pwd}"
        CacheFile.new cache_dir, @args
      end

      def execute
        stack "@args: #{@args}".cyan
        cachefile = cache_file
        cachefile.readlines
      end
    end
  end
end
