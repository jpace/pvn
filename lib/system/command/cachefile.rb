#!/usr/bin/ruby -w
# -*- ruby -*-

require 'system/command/line'
require 'zlib'

module System
  class CacheFile
    include Loggable
    
    def initialize cache_dir, args
      info "cache_dir: #{cache_dir}"
      # pwd = Pathname.pwd.split_path.join('')
      # info "pwd: #{pwd}"
      @args = args
      @pn = Pathname.new(cache_dir) + args.join('-').gsub('/', '\/')
      info "pn: #{@pn}".yellow

      @lines = nil
   end

    def save_file output
      @pn.parent.mkpath
      info "saving output to cache file: #{@pn}".blue
      File.put_via_temp_file @pn.to_s do
        output
      end
      output
    end

    def read_file
      info "reading from cache file: #{@pn}".cyan
      @lines = @pn.readlines
    end

    def readlines
      if @pn.exist?
        read_file
      else
        cl = CommandLine.new @args
        output = cl.execute

        save_file output
        output
      end
    end

    def to_s
      @pn.to_s
    end
  end
end
