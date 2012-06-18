#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/base/command/cachecmd'
require 'pvn/base/command/cmdline'

module PVN
  module SVN
    class Revision
      attr_reader :from_revision
      attr_reader :to_revision

      attr_reader :from_date
      attr_reader :to_date

      def initialize args
        @from_revision = args[:from_revision]
        @to_revision   = args[:to_revision]

        @from_date     = args[:from_date]
        @to_date       = args[:to_date]
      end

      def arguments
        args = Array.new
        if @from_revision && @to_revision
          args << "-r" << "#{@from_revision}:#{@to_revision}"
        elsif @from_date && @to_date
          args << "-r" << "\{#{@from_date}\}:\{#{@to_date}\}"
        end
        args
      end
    end    
    
    class LogOptions
      attr_reader :revision
    end
    
    class LogCommandLine < CommandLine
      def initialize(*args)
        cmdargs = %w{ svn log }.concat args
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
