#!/usr/bin/ruby -w
# -*- ruby -*-

require 'system/command/arg'

module System
  class CommandLine
    include Loggable

    attr_reader :output

    def initialize args = Array.new
      @args = args.dup
    end

    def << arg
      # @args << Argument.new(arg)
      @args << arg
    end

    def execute
      cmd = to_command
      info "cmd: #{cmd}"
      @output = ::IO.popen(cmd).readlines
    end

    def to_command
      @args.join ' '
    end
  end
end
