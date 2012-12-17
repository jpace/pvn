#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'svnx/log/entries'
require 'pvn/revision/range'

require 'resources'

module PVN::Revision
  class RangeTestCase < PVN::TestCase
    def test_init
      rr = Range.new '143:199'
      assert_equal '143', rr.from.to_s
      assert_equal '199', rr.to.to_s
      assert_equal '143:199', rr.to_s
    end

    def test_to_working_copy
      rr = Range.new '143'
      assert_equal '143', rr.from.to_s
      assert_nil rr.to
      assert_equal '143', rr.to_s
    end
  end
end
