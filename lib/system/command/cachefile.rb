#!/usr/bin/ruby -w
# -*- ruby -*-

require 'riel'
require 'rubygems'

module PVN
  module System
    # this will become CommandLine
    class CacheFile
      include Loggable
      
      def initialize cache_dir, args
        pwd = Pathname.pwd.split_path.join('')
        info "pwd: #{pwd}"
        @command = args.join ' '
        @pn = Pathname.new(cache_dir) + pwd + args.join('-')
      end

      def readlines
        if @pn.exist?
          debug "reading from cache file: #{self}".cyan
          @pn.readlines
        else
          output = IO.popen(@command).readlines
          @pn.parent.mkpath
          debug "saving output to cache file: #{self}".on_cyan
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
end
