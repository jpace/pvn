#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'pvn/subcommands/diff/command'
require 'resources'
require 'stringio'

Log.level = Log::DEBUG

module PVN::Subcommands::Diff
  class CommandTest < PVN::TestCase

    # the tests previously herewith have been moved to local and repository
    # differ tests.

    def test_nothing
    end
  end
end
