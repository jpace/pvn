#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/base/command/cachecmd'
require 'pvn/base/command/cmdline'
require 'pvn/svn/revision/revision'

module PVN
  module SVN
    class LogOptions
      attr_reader :revision
    end
    
    class LogCommandLine < CommandLine
      def initialize(*args)
        cmdargs = %w{ svn log --xml }.concat args
        info "cmdargs: #{cmdargs}".blue
        super cmdargs
      end

      def cache_dir
        "/tmp/cache_dir_for_log_command"
      end

      def use_cache?
        true
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
        command = %w{ svn log }

        @revision = Revision.new args
        command.concat @revision.arguments
        debug "command: #{command}".on_red

        args[:command_args] = command

        super
        
        @log = nil
      end

      def command_line
        LogCommandLine.new 
      end
      
      def execute
        cmdline = command_line
        cmdline.execute
        
        @output = cmdline.output
      end
    end
  end
end
