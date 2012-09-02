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

  class LogCommandLine < CommandLine
    def initialize args = Array.new
      info "args: #{args}"
      super "log", args.to_a
    end
  end

  class LogCommandLineCaching < CachingCommandLine
    def initialize args = Array.new
      info "args: #{args}"
      super "log", args.to_a
    end

    def cache_dir
      PVN::Environment.instance.cache_dir
    end
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
      ary = Array.new
      if @limit
        ary << '--limit' << @limit
      end
      if @verbose
        ary << '-v'
      end

      if @revision
        @revision.each do |rev|
          ary << "-r#{rev}"
        end
      end

      if @path
        ary << @path
      end
      
      ary.compact
    end
  end
  
  class LogCommand < Command
    def initialize args
      @use_cache = args.use_cache
      super
    end

    def command_line
      @use_cache ? LogCommandLineCaching.new(@args) : LogCommandLine.new(@args)
    end
  end
end
