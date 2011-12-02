#!/usr/bin/ruby -w
# -*- ruby -*-

require 'riel'
require 'rubygems'
require 'pvn/command/cmdexec'
require 'pvn/command/command'
require 'pvn/option/optional'
require 'pvn/util'

module PVN
  class CachableCommand < Command
    include Optional
    include Loggable

    TMP_DIR = ENV['PVN_TMP_DIR'] || '/tmp/pvncache'
    CACHE_DIR = Pathname.new TMP_DIR

    attr_accessor :lines

    def initialize args = Hash.new
      debug "args: #{args.inspect}".yellow

      @use_cache = args[:use_cache].nil? ? true : args[:use_cache]
      debug "@use_cache: #{@use_cache}".on_blue

      super
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

    def to_command args
      args[:command].join(' ')
    end

    def get_cache_file args
      pwd = Pathname.pwd.to_s.sub(%r{^/}, '')
      CACHE_DIR + pwd + command.gsub(' ', '')
    end

    def run_cached_command args
      debug "args: #{args}".cyan
      cfile = get_cache_file args
      if cfile.exist?
        @output = cfile.readlines
      else
        run_command
        cfile.parent.mkpath
        File.put_via_temp_file cfile do
          output
        end
      end
    end
  end
end