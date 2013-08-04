require 'rubygems'
require 'logue/log'
require 'stringio'
require 'test/unit'
require 'resources'
require 'rainbow'

Logue::Log.level = Logue::Log::DEBUG
Logue::Log.set_widths(-35, 4, -35)

# produce colorized output, even when redirecting to a file:
Sickill::Rainbow.enabled = true

module PVN
  class TestCase < Test::Unit::TestCase
    include Logue::Loggable
    
    def setup
    end
    
    def test_truth
      assert true
    end
  end
end
