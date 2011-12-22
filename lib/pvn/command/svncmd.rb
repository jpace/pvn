#!/usr/bin/ruby -w
# -*- ruby -*-

require 'riel'
require 'rubygems'
require 'pvn/command/cmdexec'
require 'pvn/command/cachecmd'

module PVN
  class SVNCommand < CachableCommand
    def initialize args = Hash.new
      super
      info "self: #{self}".yellow
    end

    def to_svn_command fullcmdargs
      [ "svn", self.class::COMMAND ] + fullcmdargs
    end

    def command
      @svncmd.join(" ")
    end

    def execute
      cmdline = options.as_command_line
      @svncmd = to_svn_command cmdline
      info "@svncmd: #{@svncmd}"
      cmd = @svncmd.join(" ")
      sysexec cmd
      # @output = IO.popen(cmd).readlines
    end
  end
end
