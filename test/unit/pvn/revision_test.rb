#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'svnx/log/entries'
require 'pvn/revision'

require 'resources'

module PVN
  class RevisionTestCase < PVN::TestCase
    def setup
      # This is the equivalent of "log" at revision 22, when this file was added
      # at revision 13. Using this instead of just "log" when regenerating the
      # resource files keeps the revisions from bouncing around.
      @xmllines = Resources::PT_LOG_R22_13_SECONDFILE_TXT.readlines
    end

    def create_revision value
      PVN::Revision.new value, @xmllines
    end

    def assert_revision_entry exp_value, value
      rev = create_revision value
      assert_equal exp_value, rev.value
    end

    def assert_revision_entry_raises value
      assert_raises(PVN::RevisionError) do 
        assert_revision_entry nil, value
      end
    end

    def assert_revision_to_s exp_str, value
      rev = create_revision value
      assert_equal exp_str, rev.to_s
    end      

    def test_absolute_midrange
      assert_revision_entry 19, 19
    end

    def test_absolute_most_recent
      assert_revision_entry 22, 22
    end

    def test_absolute_least_recent
      assert_revision_entry 13, 13
    end

    def test_absolute_midrange_as_string
      assert_revision_entry 19, '19'
    end

    def test_absolute_most_recent_as_string
      assert_revision_entry 22, '22'
    end

    def test_absolute_least_recent_as_string
      assert_revision_entry 13, '13'
    end

    def test_svn_word
      assert_revision_entry 'HEAD', 'HEAD'
      %w{ HEAD BASE COMMITTED PREV }.each do |word|
        assert_revision_entry word, word
      end
    end

    def test_negative_most_recent
      assert_revision_entry 22, -1
    end

    def test_negative_second_most_recent
      assert_revision_entry 20, -2
    end

    def test_negative_least_recent
      assert_revision_entry 13, -5
    end

    def test_negative_too_far_back
      assert_revision_entry_raises(-6)
    end

    def test_negative_most_recent_as_string
      assert_revision_entry 22, '-1'
    end

    def test_negative_second_most_recent_as_string
      assert_revision_entry 20, '-2'
    end

    def test_negative_least_recent_as_string
      assert_revision_entry 13, '-5'
    end

    def test_negative_too_far_back_as_string
      assert_revision_entry_raises '-6'
    end

    def test_positive_most_recent
      assert_revision_entry 22, '+5'
    end

    def test_positive_second_most_recent
      assert_revision_entry 20, '+4'
    end

    def test_positive_least_recent
      assert_revision_entry 13, '+1'
    end

    def test_positive_too_far_forward
      assert_revision_entry_raises '+6'
    end

    def xxxtest_range_svn_word_to_number
      assert_revision_entry 'BASE:1', 'BASE:1'
    end

    def xxxtest_date
      assert_revision_to_s '1967-12-10', '1967-12-10'
    end

    def test_to_s
      assert_revision_to_s '5', '5'
      assert_revision_to_s 'HEAD', 'HEAD'
    end
  end

  class RevisionRangeTestCase < PVN::TestCase
    def test_init
      rr = RevisionRange.new '143:199'
      assert_equal '143', rr.from.to_s
      assert_equal '199', rr.to.to_s
      assert_equal '143:199', rr.to_s
    end

    def test_to_working_copy
      rr = RevisionRange.new '143'
      assert_equal '143', rr.from.to_s
      assert_nil rr.to
      assert_equal '143', rr.to_s
    end
  end
end