#!/usr/bin/ruby -w
# -*- ruby -*-

module PVN
  class CommandExecutor
    def initialize
    end

    def run(cmd)
      IO.popen(cmd).readlines
    end
  end
end
