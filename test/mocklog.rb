require File.dirname(__FILE__) + '/test_helper.rb'

require 'rubygems'
require 'riel'
require 'singleton'
require 'pvn/log'
require 'pvn/cmdexec'

module PVN
  class MockLogCommand < LogCommand
    include Loggable

    @@current_file = nil
    
    def self.current_file= fname
      @@current_file = fname
    end
    
    def initialize args
      limit = args[:limit]
      n_matches = 0
      @output = Array.new
      IO.readlines(@@current_file).each do |line|
        if limit && PVN::LogCommand::LOG_REVISION_LINE.match(line)
          n_matches += 1
          if n_matches > limit
            break
          end
        end
        @output << line
      end
    end
  end
end

module PVN
  class MockCommandExecutor < CommandExecutor
    include Loggable, Singleton

    def initialize
      reset
      super()
    end

    def addfile fname
      @fnames << fname
    end

    def reset
      @fnames = Array.new
    end

    def run cmd
      # look for limit
      
      info "cmd: #{cmd}".on_magenta
    end
  end
end
