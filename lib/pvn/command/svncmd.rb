#!/usr/bin/ruby -w
# -*- ruby -*-

require 'riel'
require 'rubygems'
require 'pvn/command/cmdexec'
require 'pvn/command/cachecmd'
require 'pvn/util'

module PVN
  class SVNCommand < CachableCommand
    def initialize args = Hash.new
      super

      info "self: #{self}".yellow
      
      # debug "args: #{args}"
      # @execute  = args[:execute].nil? || args[:execute]
      # @executor = args[:executor] || CommandExecutor.new

      # args[:command_args] ||= Array.new

      # set_options args
      
      # cmdline = get_command_line args
      
      # if args[:filename]
      #   cmdline << args[:filename]
      # end

      # run_command_line cmdline
    end

    def run_command_line cmdline
      @svncmd = to_svn_command cmdline
      run @svncmd
    end

    def to_svn_command fullcmdargs
      [ "svn", self.class::COMMAND ] + fullcmdargs
    end

    def command
      @svncmd.join(" ")
    end

    def run_command
      @output = @executor.run command
    end

    def execute cmd
      IO.popen(cmd).readlines
    end
  end
end
