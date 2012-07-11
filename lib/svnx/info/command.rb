#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/command'

module SVNx
  class InfoCommandLine < CommandLine
    def initialize args = Array.new
      super "info", args
    end
  end

  class InfoCommandArgs < CommandArgs
  end  

  class InfoCommand < Command
    def command_line
      InfoCommandLine.new @cmdargs
    end
  end
end
