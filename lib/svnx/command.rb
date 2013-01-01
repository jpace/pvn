#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'system/command/line'
require 'riel/log/loggable'
require 'system/command/caching'

# this replaces svnx/lib/command/svncommand.

module SVNx
  DEFAULT_CACHE_DIR = '/tmp/svnx'
  TMP_DIR_ENV_VARNAME = 'SVNX_TMP_DIR'

  module CmdLine
    include RIEL::Loggable

    def initialize subcmd, args
      # info "args: #{args}"
      cmdargs = [ 'svn', subcmd ]
      cmdargs << '--xml' if uses_xml?
      # info "cmdargs: #{cmdargs}"
      cmdargs.concat args
      # info "cmdargs: #{cmdargs}"
      super cmdargs
    end

    def uses_xml?
      true
    end

    def cache_dir
      ENV[TMP_DIR_ENV_VARNAME] || DEFAULT_CACHE_DIR
    end
  end

  class CommandLine < System::CommandLine
    include CmdLine
  end

  class CachingCommandLine < System::CachingCommandLine
    include CmdLine
  end

  class CommandArgs
    include RIEL::Loggable
    
    attr_accessor :path

    def initialize args = Hash.new
      @path = args[:path]
    end

    def to_a
      [ @path ].compact
    end
  end  

  class Command
    include RIEL::Loggable

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
