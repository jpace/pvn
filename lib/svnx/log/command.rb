#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'system/command/line'
require 'system/command/caching'
require 'pvn/svn/environment'
require 'svnx/command'

module SVNx
  CACHE_DIR = "/tmp/cache_dir_for_log_command"

  class LogOptions
    attr_reader :revision
  end    

  class LogCommandLine < CommandLine
    def initialize args = Array.new
      super "log", args.to_a
    end
  end

  class LogCommandLineCaching < CachingCommandLine
    def initialize args = Array.new
      super "log", args.to_a
    end

    def cache_dir
      PVN::Environment.instance.cache_dir
    end
  end

  class LogOptions
  end

  class LogCommandArgs < CommandArgs
    include Loggable
    
    attr_reader :limit
    attr_reader :verbose
    attr_reader :revision
    attr_reader :use_cache

    def initialize args = Hash.new
      @limit = args[:limit]
      @verbose = args[:verbose]
      @use_cache = args[:use_cache].nil? || args[:use_cache]
      @revision = args[:revision]
      info "args      : #{args}"
      info "@limit    : #{@limit}"
      info "@verbose  : #{@verbose}"
      info "@use_cache: #{@use_cache}"
      info "@revision : #{@revision}"

      super
    end

    def to_a
      info "@revision: #{@revision}".red
      [ @limit && "--limit #{@limit}", @verbose && '-v', @revision && "-r#{@revision}", @path ].compact
    end
  end
  
  class LogCommand < Command
    def initialize args
      stack "args: #{args}".on_red
      info "args.to_a: #{args.to_a}".on_red
      @use_cache = args.use_cache
      super
    end

    def command_line
      info "@args: #{@args}"
      cmdline = @use_cache ? LogCommandLineCaching.new(@args) : LogCommandLine.new(@args)
      info "cmdline: #{cmdline}"
      cmdline
    end
  end
end
