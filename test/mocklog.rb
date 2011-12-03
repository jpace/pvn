require File.dirname(__FILE__) + '/test_helper.rb'

require 'rubygems'
require 'riel'
require 'singleton'
require 'pvn/log'
require 'pvn/command/cmdexec'

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

module PVN
  class MockSVNExecutor < CommandExecutor
    include Loggable

    def initialize location
      @location = location
      
      super()
    end

    def run cmd
      info "cmd: #{cmd}".on_magenta
    end
  end
end

module PVN
  class MockLogExecutor < CommandExecutor
    include Loggable

    def file=(fname)
      @file = fname
    end

    def run args
      log "args: #{args}"
      cmd, subcmd, *cmdargs = args.split
      info "cmd: #{cmd}"
      info "subcmd: #{subcmd}"
      info "cmdargs: #{cmdargs}".on_black

      limit = nil

      if idx = cmdargs.index("-l")
        info "idx: #{idx}".on_yellow
        limit = cmdargs[idx + 1].to_i
      end

      info "limit: #{limit}"
      
      n_matches = 0
      output = Array.new
      IO.readlines(@file).each do |line|
        if limit && PVN::Log::SVN_LOG_REVISION_LINE_RE.match(line)
          n_matches += 1
          if n_matches > limit
            break
          end
        end
        output << line
      end

      # puts output

      output
    end
  end
end
