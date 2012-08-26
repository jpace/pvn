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

      IO.popen(cmd) do |io|
        @output = io.readlines
      end

      if $? && $?.exitstatus != 0
        info "cmd: #{cmd}".red
        info "$?: #{$?.inspect}".red
        info "$?.exitstatus: #{$? && $?.exitstatus}".red
        raise "ERROR running command #{cmd}: #{$?}"
      end

      @output
    end

    def to_command
      @args.join ' '
    end
  end
end
