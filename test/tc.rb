require 'rubygems'
require 'riel'
require 'stringio'
require 'test/unit'

Log.level = Log::DEBUG
Log.set_widths(-35, 4, -35)

module PVN
  class TestCase < Test::Unit::TestCase
    include Loggable
    
    def setup
    end
    
    def test_truth
      assert true
    end
  end
end
