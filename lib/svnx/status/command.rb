#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/command'

module SVNx
  class StatusCommandLine < CommandLine
    def initialize args = Array.new
      super "status", args.to_a
    end
  end

  class StatusCommandArgs < CommandArgs
    def to_a
      ary = Array.new
      if @path
        ary << @path
      end
      ary
    end
  end  

  class StatusCommand < Command
    def command_line
      StatusCommandLine.new @args
    end
  end
end
