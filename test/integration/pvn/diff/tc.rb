#!/usr/bin/ruby -w
# -*- ruby -*-

require 'integration/tc'
require 'pvn/diff/command'
require 'pvn/diff/options'

module PVN::Diff
  class TestCase < PVN::IntegrationTestCase
    def assert_diff_command diffcls, args, explines
      assert_command_option_output diffcls, OptionSet, args, explines
    end
  end
end
