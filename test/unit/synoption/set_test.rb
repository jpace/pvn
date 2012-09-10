#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'synoption/set'
require 'synoption/base_option'

module PVN
  class SetTestCase < Test::Unit::TestCase
    include Loggable

    class TestOptionSet < OptionSet
      def name
        'test'
      end
    end

    def setup
      @xyz = BaseOption.new :xyz, '-x', "blah blah xyz",    nil
      @abc = BaseOption.new :abc, '-a', "abc yadda yadda",  nil
      @tnt = BaseOption.new :tnt, '-t', "tnt and so forth", nil
      
      @optset = TestOptionSet.new [ @xyz, @abc, @tnt ]
    end

    def test_find_by_name
      assert_not_nil @optset.find_by_name(:xyz)
      assert_nil @optset.find_by_name(:bfd)
    end

    def test_process
      @optset.process %w{ -x foo }
      
      assert_equal 'foo', @xyz.value
      assert_nil @abc.value
      assert_nil @tnt.value
    end

    def test_bad_option
      assert_raises(OptionException) do
        @optset.process %w{ -y foo }
      end
    end

    def test_stop_on_double_dash
      @optset.process %w{ -- -x foo }
      
      assert_nil @xyz.value
      assert_nil @abc.value
      assert_nil @tnt.value
    end
  end
end
