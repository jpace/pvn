#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/command'

module SVNx
  class InfoCommandLine < CommandLine
    def initialize args = Array.new
      super "info", args.to_a
    end
  end

  class InfoCommandArgs < CommandArgs
    def to_a
      ary = Array.new
      if @path
        ary << @path
      end
      ary
    end
  end  

  class InfoCommand < Command
    def command_line
      InfoCommandLine.new @args
    end
  end
end
