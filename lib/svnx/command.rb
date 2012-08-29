#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'system/command/line'

# this replaces svnx/lib/command/svncommand.

module SVNx
  class CommandLine < System::CommandLine
    def initialize subcmd, args = Array.new
      info "args: #{args}"
      cmdargs = [ 'svn', subcmd, '--xml' ].concat args
      info "cmdargs: #{cmdargs}"
      super cmdargs
    end
  end

  class CachingCommandLine < System::CachingCommandLine
    def initialize subcmd, args = Array.new
      info "args: #{args}"
      cmdargs = [ 'svn', subcmd, '--xml' ].concat args
      info "cmdargs: #{cmdargs}"
      super cmdargs
    end
  end

  class CommandArgs
    attr_accessor :path

    def initialize args = Hash.new
      @path = args[:path]
    end

    def to_a
      [ @path ].compact
    end
  end  

  class Command
    include Loggable

    attr_reader :output
    
    def initialize args
      @args = args
    end

    def command_line
      raise "must be implemented"
    end
    
    def execute
      cmdline = command_line
      cmdline.execute
      @output = cmdline.output
    end
  end
end
