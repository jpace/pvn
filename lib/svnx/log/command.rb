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
      cmdargs = %w{ svn log --xml }.concat args
      super cmdargs
    end
  end

  class LogCommandLineCaching < System::CachingCommandLine
    def initialize args = Array.new
      cmdargs = %w{ svn log --xml }.concat args
      super cmdargs
    end

    def cache_dir
      PVN::Environment.instance.cache_dir
    end
  end

  class LogCommandArgs
  end

  class LogOptions
  end
  
  class LogCommand # < PVN::CachableCommand
    include Loggable

    attr_reader :log
    attr_reader :output
    
    def initialize args = Hash.new
      info "args: #{args.inspect}"
      
      command = %w{ svn log }

      @use_cache = args[:use_cache].nil? ? true : args[:use_cache]
      info "@use_cache: #{@use_cache}"

      # args[:command_args] = command

      @cmdargs = args[:command_args] || Array.new

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
