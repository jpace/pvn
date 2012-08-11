#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'pvn/revision/argument'

module PVN
  module Revisionxxx
    class ArgumentTestCase < PVN::TestCase
      def assert_argument exp_value, value
        arg = PVN::Revisionxxx::Argument.new value
        assert_value arg, exp_value
      end

      def assert_value arg, exp_value
        assert_equal exp_value, arg.value
        arg
      end

      def assert_pos_neg arg, exp_pos, exp_neg
        assert_equal exp_neg, arg.negative?
        assert_equal exp_pos, arg.positive?
        arg
      end

      def test_string_to_number
        arg = assert_argument '733', '733'
        assert_pos_neg arg, false, false
      end

      def test_fixnum_to_number
        arg = assert_argument '733', 733
        assert_pos_neg arg, false, false
      end

      def test_svn_keywords
        %w{ HEAD BASE COMMITTED PREV }.each do |word|
          arg = assert_argument word, word
          assert_pos_neg arg, false, false
        end
      end

      def test_negative_fixnum
        arg = assert_argument '1', -1
        assert_pos_neg arg, false, true
      end

      def test_negative_string
        arg = assert_argument '1', '-1'
        assert_pos_neg arg, false, true
      end

      def test_positive_string
        arg = assert_argument '1', '+1'
        assert_pos_neg arg, true, false
      end
    end
  end
end
