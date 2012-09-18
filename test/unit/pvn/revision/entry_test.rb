#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'svnx/log/entries'
require 'pvn/revision/entry'

require 'resources'

module PVN::Revision
  class TestCase < PVN::TestCase
    def setup
      # if we do this, regenerating the resource files won't bump the revisions
      # around:
      # Resources::PT_LOG_R13_22_SECONDFILE_TXT.readlines
      @xmllines = Resources::PT_LOG_SECONDFILE_TXT.readlines
    end

    def assert_revision_entry exp_value, value
      rev = PVN::Revision::Entry.new :xmllines => @xmllines, :value => value
      assert_equal exp_value, rev.value
    end

    def assert_revision_entry_raises value
      assert_raises(PVN::Revision::RevisionError) do 
        assert_revision_entry nil, value
      end
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
  end
end
