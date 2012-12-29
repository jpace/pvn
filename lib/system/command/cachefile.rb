#!/usr/bin/ruby -w
# -*- ruby -*-

require 'system/command/line'
require 'zlib'
require 'riel/log/loggable'

module System
  class CacheFile
    include RIEL::Loggable

    attr_reader :output
    
    def initialize cache_dir, args
      @args = args
      @pn = Pathname.new(cache_dir) + (args.join('-').gsub('/', '_slash_') + '.gz')
      @output = nil
    end

    def save_file
      @pn.parent.mkpath unless @pn.parent.exist?
      @pn.unlink if @pn.exist?
      Zlib::GzipWriter.open(@pn.to_s) do |gz|
        gz.puts @output
      end
    end

    def read_file
      Zlib::GzipReader.open(@pn.to_s) do |gz|
        @output = gz.readlines
      end
      @output
    end

    def readlines
      if @pn.exist?
        read_file
      else
        cl = CommandLine.new @args
        @output = cl.execute
        save_file
        @output
      end
    end

    def to_s
      @pn.to_s
    end
  end
end
