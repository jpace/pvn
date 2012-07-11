#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'system/cachecmd'
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
      super "log", args
    end
  end

  class LogCommandLineCaching < CachingCommandLine
    def initialize args = Array.new
      super "log", args
    end

    def cache_dir
      PVN::Environment.instance.cache_dir
    end
  end

  class LogOptions
  end

  class LogCommandArgs < CommandArgs
    attr_accessor :limit
    attr_accessor :verbose

    def initialize args = Hash.new
      @limit = args[:limit]
      @verbose = args[:verbose]
      super
    end

    def to_a
      [ @limit ? "--limit #{@limit}" : nil, @path, @verbose ? '-v' : nil ].compact
    end
  end
  
  class LogCommand < Command    
    def initialize args = Hash.new
      @use_cache = args[:use_cache].nil? ? true : args[:use_cache]
      super
    end

    def command_line
      @use_cache ? LogCommandLineCaching.new(@cmdargs) : LogCommandLine.new(@cmdargs)
    end
  end
end
