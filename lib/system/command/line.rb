#!/usr/bin/ruby -w
# -*- ruby -*-

require 'riel'
require 'rubygems'
require 'system/command/arg'
require 'system/command/cachefile'

module PVN
  module System
    # this will become CommandLine
    class CommandLineNonCached
      include Loggable

      attr_reader :output

      def initialize args = Array.new
        @args = args.dup
      end

      def << arg
        # @args << Argument.new(arg)
        @args << arg
      end

      def execute
        @output = ::IO.popen(to_command).readlines
      end

      def to_command
        @args.join ' '
      end
    end

    # this will become CachableCommandLine
    class CommandLine < CommandLineNonCached
      attr_accessor :use_cache

      def initialize use_cache, args = Array.new
        @use_cache = use_cache
        super args
      end

      def use_cache?
        @use_cache
      end

      def cache_dir
        nil
      end

      def execute
        if use_cache?
          run_cached_command
        else
          super
        end
      end

      def cache_file
        pwd = Pathname.pwd.split_path.join('')
        info "pwd: #{pwd}"
        # Pathname.new(cache_dir) + pwd + @args.join('-')
        CacheFile.new cache_dir, @args
      end

      def run_cached_command
        stack "@args: #{@args}".cyan
        cachefile = cache_file
        cachefile.readlines
      end
    end
  end
end
