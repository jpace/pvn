#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'pvn/diff/revision'

module PVN::Diff
  class RevisionTestCase < PVN::TestCase
    def to_message change, revision
      "change: #{change}; revision: #{revision}"
    end   

    def assert_revision_to_s expstr, change, revision
      rev = RevisionRange.new change, revision
      assert_equal expstr, rev.to_s, "change: #{change}; revision: #{revision}"
    end   

    def assert_revision_gt exp, chgx, revx, chgy, revy
      x = RevisionRange.new chgx, revx
      y = RevisionRange.new chgx, revy
      msg = "x: #{to_message(chgx, revx)}; y: #{to_message(chgy, revy)}"
      info "x: #{x}".cyan
      info "y: #{y}".cyan
      assert_equal exp, x > y, msg
    end
   
    def test_change_str
      assert_revision_to_s '14:15', '15', nil
    end

    def test_revision_str
      assert_revision_to_s '14:15', nil, [ '14', '15' ]
    end
  end
end
