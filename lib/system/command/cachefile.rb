#!/usr/bin/ruby -w
# -*- ruby -*-

require 'system/command/line'

module System
  class CacheFile
    include Loggable
    
    def initialize cache_dir, args
      # pwd = Pathname.pwd.split_path.join('')
      # info "pwd: #{pwd}"
      @args = args
      @pn = Pathname.new(cache_dir) + args.join('-').gsub('/', '\/')
      info "pn: #{@pn}".yellow
    end

    def readlines
      if @pn.exist?
        info "reading from cache file: #{@pn}".cyan
        @pn.readlines
      else
        cl = CommandLine.new @args
        output = cl.execute

        @pn.parent.mkpath
        info "saving output to cache file: #{@pn}"
        File.put_via_temp_file @pn.to_s do
          output
        end
        output
      end
    end

    def to_s
      @pn.to_s
    end
  end
end
