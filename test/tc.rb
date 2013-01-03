require 'rubygems'
require 'riel/log'
require 'stringio'
require 'test/unit'
require 'resources'
require 'rainbow'

Log.level = Log::DEBUG
Log.set_widths(-35, 4, -35)

# produce colorized output, even when redirecting to a file:
Sickill::Rainbow.enabled = true

module PVN
  class TestCase < Test::Unit::TestCase
    include RIEL::Loggable
    
    def setup
    end
    
    def test_truth
      assert true
    end
  end
end
