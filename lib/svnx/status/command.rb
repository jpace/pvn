#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'svnx/command'

module SVNx
  class StatusCommandLine < CommandLine
    def initialize args = Array.new
      super "status", args
    end
  end

  class StatusCommandArgs < CommandArgs
  end  

  class StatusCommand < Command
    def command_line
      StatusCommandLine.new @cmdargs
    end
  end
end
