#!/usr/bin/ruby -w
# -*- ruby -*-

require 'riel'
require 'rubygems'
require 'system/cachecmd'

module PVN
  # A command that is a simple pass-through (more or less)
  # to a svn command.
  class SVNCommand < CachableCommand
    def self.revision_from_args optset, cmdargs
      require 'pvn/revision'
      Revision.revision_from_args optset, cmdargs
    end

    def initialize args = Hash.new
      super
      info "self: #{self}"
    end

    def to_svn_command fullcmdargs
      [ "svn", self.class::COMMAND ] + fullcmdargs
    end

    def command
      @svncmd.join " "
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
