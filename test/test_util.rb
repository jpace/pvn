require 'test_helper'

require 'pvn/util'

module PVN
  class TestUtil < Test::Unit::TestCase
    
    def setup
    end

    def assert_true boolean, message = nil
      assert boolean, message
    end
    
    def assert_false boolean, message = nil
      assert !boolean, message
    end
    
    def assert_negative_integer val
      assert_true Util.negative_integer? val
    end
    
    def assert_not_negative_integer val
      assert_false Util.negative_integer? val
    end
    
    def test_negative_integer
      assert_negative_integer(-3)
      assert_negative_integer("-3")
      assert_negative_integer(-10)
      assert_negative_integer "-15"
      assert_negative_integer(-100)
      assert_negative_integer "-9002"

      assert_not_negative_integer 1
      assert_not_negative_integer "1"
      assert_not_negative_integer 1.5
      assert_not_negative_integer "5.1"
      assert_not_negative_integer 123
      assert_not_negative_integer "123"
      assert_not_negative_integer "negative three"
    end
  end
end
