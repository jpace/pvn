#!/usr/bin/ruby -w
# -*- ruby -*-

require 'integration/tc'
require 'pvn/pct/options'

module PVN::Pct
  class TestCase < PVN::IntegrationTestCase
    def assert_command cmdcls, explines, args
      assert_command_option_output cmdcls, OptionSet, args, explines
    end
  end
end
