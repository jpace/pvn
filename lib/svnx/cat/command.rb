#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/command'
require 'system/command/caching'

module SVNx
  module CatCmdLine
    # this can be either an Array (for which to_a returns itself), or a
    # CommandArgs, which also has to_a.
    def initialize args = Array.new
      super "cat", args.to_a
    end

    def uses_xml?
      false
    end
  end
  
  class CatCommandLine < CommandLine
    include CatCmdLine
  end

  class CatCommandLineCaching < CachingCommandLine
    include CatCmdLine
  end

  class CatCommandArgs < CommandArgs
    attr_reader :revision
    attr_reader :use_cache

    def initialize args = Hash.new
      @use_cache = args[:use_cache].nil? || args[:use_cache]
      @revision = args[:revision]
      super
    end

    def to_a
      ary = Array.new
      if @revision
        ary << "-r#{@revision}"
      end
      
      if @path
        ary << @path
      end
    end
  end  

  class CatCommand < Command
    def initialize args
      @use_cache = args.use_cache
      super
    end

    def command_line
      cls = @use_cache ? CatCommandLineCaching : CatCommandLine
      cls.new @args
    end
  end
end
