require File.dirname(__FILE__) + '/test_helper.rb'

require 'rubygems'
require 'riel'
require 'pvn/revision'
require 'pvn/log'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module PVN
  class MockLogCommand < LogCommand
    def initialize args
      puts "args: #{args}"
    end
  end    

  class TestRevision < Test::Unit::TestCase
    def setup
    end

    def assert_revision exp, val
      rev = Revision.new(val, "foo", MockLogCommand)
      assert_equal exp, rev.revision
    end
    
    def test_negative_integer
      assert_revision 4, 4
    end
  end
end
