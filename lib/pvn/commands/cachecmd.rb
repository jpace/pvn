#!/usr/bin/ruby -w
# -*- ruby -*-

require 'riel'
require 'rubygems'
require 'pvn/cmdexec'
require 'pvn/option/optional'
require 'pvn/util'

module PVN
  class CachableCommand
    include Optional
    include Loggable

    TMP_DIR = ENV['PVN_TMP_DIR'] || '/tmp/svncache'
    CACHE_DIR = Pathname.new TMP_DIR

    attr_accessor :lines

    def initialize args
      info "args: #{args}"

      cmd = args.join(' ')

      if use_cache?
        run_cached_command cmd
      else
        run_command cmd
      end      
    end

    def use_cache?
      true
    end

    def get_cache_file cmd
      pwd = Pathname.pwd.to_s.sub(%r{^/}, '')

      fname = CACHE_DIR + pwd + cmd.gsub(' ', '')
      info "fname: #{fname}"
      fname
    end

    def run_cached_command cmd
      cfile = get_cache_file cmd
      if cfile.exist?
        @lines = cfile.readlines
      else
        cfile.parent.mkpath
        run_command cmd
        File.put_via_temp_file cfile do
          @lines
        end
      end
    end

    def run_command cmd
      IO.popen(cmd) do |io|
        @lines = io.readlines
      end
    end
  end
end
