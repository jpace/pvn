#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'svnx/log/entries'
require 'pvn/revision/entry'

require 'resources'

Log.level = Log::DEBUG

module PVN::Revision
  class TestCase < PVN::TestCase
    def setup
      lines = Resources.instance.test_lines '/Programs/wiquery/trunk', "svn", "log", "--xml", "pom.xml"
      @xmllines = lines.join('')
    end

    def assert_revision_entry exp_value, value
      rev = PVN::Revision::Entry.new :xmllines => @xmllines, :value => value
      assert_equal exp_value, rev.value
    end

    def test_absolute_midrange
      assert_revision_entry 733, 733
    end

    def test_absolute_most_recent
      assert_revision_entry 1907, 1907
    end

    def test_absolute_least_recent
      assert_revision_entry 412, 412
    end

    def test_absolute_midrange_as_string
      assert_revision_entry 733, '733'
    end

    def test_absolute_most_recent_as_string
      assert_revision_entry 1907, '1907'
    end

    def test_absolute_least_recent_as_string
      assert_revision_entry 412, '412'
    end

    def test_svn_word
      assert_revision_entry 'HEAD', 'HEAD'
      %w{ HEAD BASE COMMITTED PREV }.each do |word|
        assert_revision_entry word, word
      end
    end

    def test_negative_most_recent
      assert_revision_entry 1907, -1
    end

    def test_negative_second_most_recent
      assert_revision_entry 1887, -2
    end

    def test_negative_least_recent
      assert_revision_entry 412, -34
    end

    def test_negative_too_far_back
      assert_raises(RuntimeError) do 
        assert_revision_entry nil, -35
      end
    end

    def test_negative_most_recent_as_string
      assert_revision_entry 1907, '-1'
    end

    def test_negative_second_most_recent_as_string
      assert_revision_entry 1887, '-2'
    end

    def test_negative_least_recent_as_string
      assert_revision_entry 412, '-34'
    end

    def test_negative_too_far_back_as_string
      assert_raises(RuntimeError) do 
        assert_revision_entry nil, '-35'
      end
    end

    def test_positive_most_recent
      assert_revision_entry 1907, '+34'
    end

    def test_positive_second_most_recent
      assert_revision_entry 1887, '+33'
    end

    def test_positive_least_recent
      assert_revision_entry 412, '+1'
    end

    def test_positive_too_far_forward
      assert_raises(RuntimeError) do 
        assert_revision_entry nil, '+35'
      end
    end

    def xxxtest_range_svn_word_to_number
      assert_revision_entry 'BASE:1', 'BASE:1'
    end

    # def test_end
    #   class File
    #     def initialize args
    #       rev = args[:revision]
    #       reventry = Revision.new name, rev
    #       @revision = reventry.number
    #     end
    #   end

    #   dir = PVN::IO::File :name => "pom.xml", :revision => "-3"
    #   assert_equal 190, dir.revision
    # end
  end
end