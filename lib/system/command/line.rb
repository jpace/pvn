#!/usr/bin/ruby -w
# -*- ruby -*-

require 'riel'
require 'rubygems'
require 'system/command/arg'

module PVN
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
        @output = ::IO.popen(to_command).readlines
      end

      def to_command
        @args.join ' '
      end
    end
  end
end
