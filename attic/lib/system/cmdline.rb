#!/usr/bin/ruby -w
# -*- ruby -*-

module PVN
  class CommandLine
    include Loggable

    attr_reader :output
    attr_accessor :use_cache

    def initialize use_cache, args = Array.new
      @args = args.dup
      @use_cache = use_cache
    end

    def use_cache?
      @use_cache
    end

    def cache_dir
      nil
    end

    def << arg
      @args << arg
    end

    def execute
      if use_cache?
        run_cached_command
      else
        @output = ::IO.popen(to_command).readlines
      end
    end

    def to_command
      @args.join ' '
    end

    def run args
      if use_cache?
        run_cached_command
      else
        super
      end      
    end

    def get_cache_file
      pwd = Pathname.pwd.split_path.join('')
      info "pwd: #{pwd}"
      Pathname.new(cache_dir) + pwd + @args.join('-')
    end

    def run_cached_command
      stack "@args: #{@args}".cyan
      cachefile = get_cache_file
      if cachefile.exist?
        debug "reading from cache file: #{cachefile}".cyan
        @output = cachefile.readlines
      else
        @output = IO.popen(to_command).readlines
        cachefile.parent.mkpath
        debug "saving output to cache file: #{cachefile}".on_cyan
        File.put_via_temp_file cachefile do
          @output
        end
      end
    end
  end
end
