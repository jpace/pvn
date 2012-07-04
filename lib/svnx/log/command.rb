#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'system/cachecmd'
require 'system/command/line'
require 'system/command/caching'
require 'pvn/svn/environment'

module SVNx
  CACHE_DIR = "/tmp/cache_dir_for_log_command"

  class LogOptions
    attr_reader :revision
  end    

  class LogCommandLine < System::CommandLine
    def initialize args = Array.new
      info "args: #{args}".cyan
      cmdargs = %w{ svn log --xml }.concat args
      super cmdargs
    end
  end

  class LogCommandLineCaching < System::CachingCommandLine
    def initialize args = Array.new
      info "args: #{args}".cyan
      cmdargs = %w{ svn log --xml }.concat args
      super cmdargs
    end

    def cache_dir
      PVN::Environment.instance.cache_dir
    end
  end

  class LogOptions
  end

  class LogCommandArgs
    attr_accessor :limit
    attr_accessor :path

    def initialize args = Hash.new
      @limit = args[:limit]
      @path = args[:path]
    end

    def to_a
      [ @limit ? "--limit #{@limit}" : nil, @path ? @path : nil ].compact
    end
  end
  
  class LogCommand # < PVN::CachableCommand
    include Loggable

    attr_reader :log
    attr_reader :output
    
    def initialize args = Hash.new
      info "args: #{args.inspect}".blue
      
      @use_cache = args[:use_cache].nil? ? true : args[:use_cache]
      info "@use_cache: #{@use_cache}"

      @cmdargs = args[:cmdargs] ? args[:cmdargs].to_a : Array.new

      @use_cache = false

      # super
      
      @log = nil
    end

    def command_line
      @use_cache ? LogCommandLineCaching.new(@cmdargs) : LogCommandLine.new(@cmdargs)
    end
    
    def execute
      cmdline = command_line
      info "cmdline: #{cmdline}".cyan
      cmdline.execute
      # info "cmdline.output: #{cmdline.output}".cyan
      
      @output = cmdline.output
    end
  end
end
