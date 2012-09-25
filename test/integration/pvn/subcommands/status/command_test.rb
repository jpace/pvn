#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'pvn/subcommands/status/command'
require 'resources'
require 'stringio'

Log.level = Log::DEBUG

module PVN::Subcommands::Status
  class CommandTest < PVN::TestCase

    def test_nothing
    end
  end
end
