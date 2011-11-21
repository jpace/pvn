require File.dirname(__FILE__) + '/test_helper.rb'

require 'rubygems'
require 'riel'
require 'pvn/diff'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module PVN
  class TestCommandArgs < Test::Unit::TestCase
    def test_command_entry
      ce = CommandEntry.new(:somekey, '-x', { :default => "algo" })

      assert_equal :somekey, ce.key
      assert_equal '-x', ce.tag
      assert_equal({ :default => "algo" }, ce.options)
    end
  end
end
