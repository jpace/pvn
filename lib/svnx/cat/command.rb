#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/command'

module SVNx
  class CatCommandLine < CommandLine
    def initialize args = Array.new
      super "cat", args.to_a
    end

    def uses_xml?
      false
    end
  end

  class CatCommandArgs < CommandArgs
    attr_reader :revision
    attr_reader :use_cache

    def initialize args = Hash.new
      @use_cache = args[:use_cache].nil? || args[:use_cache]
      @revision = args[:revision]
      info "@use_cache: #{@use_cache}"
      info "@revision : #{@revision}"
      super
    end

    def to_a
      ary = Array.new
      if @revision
        @revision.each do |rev|
          ary << "-r#{rev}"
        end
      end
    
      if @path
        ary << @path
      end
    end
  end  

  class CatCommand < Command
    def command_line
      CatCommandLine.new @args
    end
  end
end
