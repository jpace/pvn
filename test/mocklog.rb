require File.dirname(__FILE__) + '/test_helper.rb'

require 'rubygems'
require 'riel'
require 'pvn/log'
require 'pvn/cmdexec'

module PVN
  class MockLogCommand < LogCommand
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
    def initialize cmdcls
      @cmdcls = cmdcls
      super()
    end

    def run cmd
      # look for limit
      
      info "cmd: #{cmd}".on_magenta
    end
  end
end
