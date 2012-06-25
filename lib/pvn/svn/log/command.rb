#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'system/cachecmd'
require 'system/command/line'
require 'pvn/svn/revision/revision'
require 'pvn/svn/environment'

module PVN
  module SVN
    CACHE_DIR = "/tmp/cache_dir_for_log_command"

    class LogOptions
      attr_reader :revision
    end
    
    class LogCommandLine < PVN::System::CommandLine
      def initialize use_cache, args = Array.new
        cmdargs = %w{ svn log --xml }.concat args
        info "cmdargs: #{cmdargs}".blue
        @use_cache = use_cache
        super use_cache, cmdargs
      end

      def cache_dir
        PVN::Environment.instance.cache_dir
      end

      def use_cache?
        @use_cache
      end
    end

    class LogCommandArgs
    end

    class LogOptions
    end
    
    class LogCommand < CachableCommand
      include Loggable

      attr_reader :log
      attr_reader :output
      
      def initialize args = Hash.new
        info "args: #{args.inspect}".on_green
        
        command = %w{ svn log }

        @revision = Revision.new args
        command.concat @revision.arguments
        debug "command: #{command}".on_red

        @use_cache = args[:use_cache].nil? ? true : args[:use_cache]
        info "@use_cache: #{@use_cache}".on_green

        args[:command_args] = command

        super
        
        @log = nil
      end

      def command_line
        LogCommandLine.new @use_cache
      end
      
      def execute
        cmdline = command_line
        cmdline.execute
        
        @output = cmdline.output
      end
    end
  end
end
