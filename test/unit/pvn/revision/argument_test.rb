#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'svnx/log/entries'
require 'pvn/revision/argument'
require 'resources'

module PVN::Revision
  class ArgumentTestCase < PVN::TestCase
    def setup
      # This is the equivalent of "log" at revision 22, when this file was added
      # at revision 13. Using this instead of just "log" when regenerating the
      # resource files keeps the revisions from bouncing around.
      @xmllines = Resources::PT_LOG_R22_13_SECONDFILE_TXT.readlines
    end

    def create_argument value
      Argument.new value, @xmllines
    end

    def assert_argument_value exp_value, value
      arg = create_argument value
      assert_equal exp_value, arg.value
    end

    def assert_argument_value_raises value
      assert_raises(PVN::Revision::RevisionError) do 
        assert_argument_value nil, value
      end
    end

    def assert_argument_to_s exp_str, value
      arg = create_argument value
      assert_equal exp_str, arg.to_s
    end      

    def assert_compare op, exp, xval, yval
      x = create_argument xval
      y = create_argument yval
      msg = "xval: #{xval}; yval: #{yval}"
      assert_equal exp, x.send(op, y), msg
    end

    def assert_argument_eq expeq, xval, yval
      # it's the emoticon programming language
      assert_compare :==, expeq, xval, yval
    end

    def assert_argument_gt expeq, xval, yval
      assert_compare :>, expeq, xval, yval
    end

    def test_absolute_midrange
      assert_argument_value 19, 19
    end

    def test_absolute_most_recent
      assert_argument_value 22, 22
    end

    def test_absolute_least_recent
      assert_argument_value 13, 13
    end

    def test_absolute_midrange_as_string
      assert_argument_value 19, '19'
    end

    def test_absolute_most_recent_as_string
      assert_argument_value 22, '22'
    end

    def test_absolute_least_recent_as_string
      assert_argument_value 13, '13'
    end

    def test_svn_word
      %w{ HEAD BASE COMMITTED PREV }.each do |word|
        assert_argument_value word, word
      end
    end

    def test_negative_most_recent
      assert_argument_value 22, -1
    end

    def test_negative_second_most_recent
      assert_argument_value 20, -2
    end

    def test_negative_least_recent
      assert_argument_value 13, -5
    end

    def test_negative_too_far_back
      assert_argument_value_raises(-6)
    end

    def test_negative_most_recent_as_string
      assert_argument_value 22, '-1'
    end

    def test_negative_second_most_recent_as_string
      assert_argument_value 20, '-2'
    end

    def test_negative_least_recent_as_string
      assert_argument_value 13, '-5'
    end

    def test_negative_too_far_back_as_string
      assert_argument_value_raises '-6'
    end

    def test_positive_most_recent
      assert_argument_value 22, '+5'
    end

    def test_positive_second_most_recent
      assert_argument_value 20, '+4'
    end

    def test_positive_least_recent
      assert_argument_value 13, '+1'
    end

    def test_positive_too_far_forward
      assert_argument_value_raises '+6'
    end

    def xxxtest_range_svn_word_to_number
      assert_argument_value 'BASE:1', 'BASE:1'
    end

    def xxxtest_date
      assert_argument_to_s '1967-12-10', '1967-12-10'
    end

    def test_to_s
      assert_argument_to_s '5', '5'
      assert_argument_to_s 'HEAD', 'HEAD'
    end

    def test_eq
      assert_argument_eq true, '5', '5'
      assert_argument_eq false, '4', '5'
      assert_argument_eq false, '5', '4'
    end

    def test_gt
      assert_argument_gt true, '17', '16'
      assert_argument_gt false, '13', '14'
    end
  end
end
