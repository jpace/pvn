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
    attr_reader :use_cache

    def initialize args = Hash.new
      @limit = args[:limit]
      @verbose = args[:verbose]
      @use_cache = args[:use_cache].nil? || args[:use_cache]
      info "@use_cache: #{@use_cache}".cyan
      super
    end

    def to_a
      [ @limit ? "--limit #{@limit}" : nil, @path, @verbose ? '-v' : nil ].compact
    end
  end
  
  class LogCommand < Command    
    def initialize args
      stack "args: #{args}".on_red
      @use_cache = args.use_cache
      super
    end

    def command_line
      @use_cache ? LogCommandLineCaching.new(@args) : LogCommandLine.new(@args)
    end
  end
end
