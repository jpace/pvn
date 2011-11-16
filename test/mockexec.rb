require File.dirname(__FILE__) + '/test_helper.rb'

require 'rubygems'
require 'riel'
require 'singleton'
require 'pvn/cmdexec'

module PVN
  class MockExecutor # < Executor
    include Loggable, Singleton

    @@current_file = nil
    
    def self.current_file= fname
      @@current_file = fname
    end
    
    def initialize args
      # parse svn commands

      cmdargs = args.split

      info "cmdargs: #{cmdargs}"

      case cmdargs[1]
      when "log"
        read_log cmdargs
      else
        info "don't know: #{cmdargs[1]}"
      end
    end

    def read_log cmdargs      
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
