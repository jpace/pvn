#!/usr/bin/ruby -w
# -*- ruby -*-

require 'riel'
require 'rubygems'
require 'pvn/command/command'
require 'pvn/base/util'

module PVN
  class CachableCommand < Command
    TMP_DIR = ENV['PVN_TMP_DIR'] || '/tmp/pvncache'
    CACHE_DIR = Pathname.new TMP_DIR

    attr_accessor :lines

    def initialize args = Hash.new
      debug "args: #{args.inspect}"

      @use_cache = args[:use_cache].nil? ? true : args[:use_cache]
      debug "@use_cache: #{@use_cache}"

      super
    end

    def sysexec cmd
      info "cmd: #{cmd}".on_red
      if use_cache?
        run_cached_command cmd
      else
        @output = ::IO.popen(cmd).readlines
      end
    end

    def run args
      if use_cache?
        run_cached_command args
      else
        super
      end      
    end

    def use_cache?
      @use_cache
    end

    def get_cache_file cmd
      pwd = Pathname.pwd.to_s.sub(%r{^/}, '')
      CACHE_DIR + pwd + cmd.gsub(' ', '')
    end

    def run_cached_command cmd
      debug "cmd: #{cmd}".cyan
      cfile = get_cache_file cmd
      if cfile.exist?
        debug "reading from cache file: #{cfile}".cyan
        @output = cfile.readlines
      else
        @output = IO.popen(cmd).readlines
        cfile.parent.mkpath
        debug "saving output to cache file: #{cfile}".cyan
        File.put_via_temp_file cfile do
          output
        end
      end
    end
  end
end
