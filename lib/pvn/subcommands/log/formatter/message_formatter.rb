#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/subcommands/log/formatter/log_formatter'

module PVN; module Log; end; end

module PVN::Log
  class MessageFormatter < Formatter
    def initialize use_colors, msg
      super use_colors
      @msg = msg
    end

    def format
      use_colors ? @msg.white : @msg
    end
  end
end
