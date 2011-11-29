#!/usr/bin/ruby -w
# -*- ruby -*-

require 'riel'
require 'rubygems'
require 'pvn/command/cmdexec'
require 'pvn/option/optional'
require 'pvn/util'

module PVN
  class CachableCommand
    include Optional
    include Loggable

    TMP_DIR = ENV['PVN_TMP_DIR'] || '/tmp/pvncache'
    CACHE_DIR = Pathname.new TMP_DIR

    attr_accessor :lines

    def initialize args = Hash.new
      info "args: #{args}"

      @use_cache = args[:use_cache].nil? ? true : args[:use_cache]
      @cmd = args[:command].join(' ')

      if use_cache?
        run_cached_command
      else
        run_command
      end      
    end

    def use_cache?
      @use_cache
    end

    def get_cache_file
      pwd = Pathname.pwd.to_s.sub(%r{^/}, '')

      fname = CACHE_DIR + pwd + @cmd.gsub(' ', '')
      info "fname: #{fname}"
      fname
    end

    def run_cached_command
      cfile = get_cache_file
      if cfile.exist?
        @lines = cfile.readlines
      else
        cfile.parent.mkpath
        run_command
        File.put_via_temp_file cfile do
          @lines
        end
      end
    end

    def run_command
      IO.popen(@cmd) do |io|
        @lines = io.readlines
      end
    end
  end
end
