#!/usr/bin/ruby -w
# -*- ruby -*-

require 'integration/tc'
require 'pvn/pct/command'

Log.level = Log::DEBUG

module PVN::Pct
  class CommandTest < PVN::IntegrationTestCase

    def test_working_copy
      explines = Array.new

      explines << "       3        4        1     33.3% FirstFile.txt"
      explines << "       3        4        1     33.3% total"
      
      assert_command_output PVN::Pct::Command, %w{ }, explines
    end

    def test_revision_to_working_copy
      explines = Array.new
      
      explines << "       3        5        2     66.7% SecondFile.txt"
      explines << "       3        5        2     66.7% total"
      
      assert_command_output PVN::Pct::Command, %w{ -r20 }, explines
    end
  end
end
