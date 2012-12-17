#!/usr/bin/ruby -w
# -*- ruby -*-

require 'system/command/line'
require 'system/command/caching'
require 'svnx/command'
require 'riel/log/loggable'

module SVNx
  module LogCmdLine
    # this can be either an Array (for which to_a returns itself), or
    # a CommandArgs, which also has to_a.
    def initialize args = Array.new
      info "args: #{args}"
      super "log", args.to_a
    end
  end

  class LogCommandLine < CommandLine
    include LogCmdLine
  end

  class LogCommandLineCaching < CachingCommandLine
    include LogCmdLine
  end

  class LogCommandArgs < CommandArgs
    include RIEL::Loggable
    
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
        [ @revision ].flatten.each do |rev|
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
      cls = @use_cache ? LogCommandLineCaching : LogCommandLine
      cls.new @args
    end
  end
end
