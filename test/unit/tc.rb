require 'rubygems'
require 'riel'

require 'stringio'
require 'test/unit'
require 'pvn_test'

# require 'pvn'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module PVN
  class TestCase < Test::Unit::TestCase
    def setup
    end
    
    def test_truth
      assert true
    end
  end
end
