#!/usr/bin/ruby -w
# -*- ruby -*-

require 'riel'
require 'rubygems'
require 'system/command/line'
require 'system/command/cachefile'

module System
  class CachingCommandLine < CommandLine
    puts "$0: #{$0}".yellow
    puts "__FILE__: #{__FILE__}".yellow
    puts "pwd: #{Pathname.pwd}".yellow

    # caches its input and values.
    @@cache_dir = '/tmp' + Pathname.new($0).expand_path

    puts "@@cache_dir: #{@@cache_dir}".yellow

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
