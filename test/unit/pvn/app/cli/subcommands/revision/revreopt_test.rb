#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'pvn/app/cli/subcommands/revision/revreopt'

Log.level = Log::DEBUG

module PVN
  class RevisionRegexpOptionTest < PVN::TestCase
    def assert_tag_match str
      assert_match RevisionRegexpOption::TAG_RE, str
    end

    def assert_tag_no_match str
      assert_no_match RevisionRegexpOption::TAG_RE, str
    end

    def test_pattern
      assert_tag_match '-r500:600'
      assert_tag_match '+1'
      assert_tag_match '-r 500'
      assert_tag_match '-1776'

      assert_tag_no_match ' -r500:600'
      assert_tag_no_match '1'
      assert_tag_no_match '123'
      assert_tag_no_match '-x'
    end

    def xxx_test_out_of_range
      assert_raises(RuntimeError) do 
        assert_relative_to_absolute '1944', '-164', '/Programs/wiquery/trunk'
      end
    end

    def assert_post_process exp, val, path
      ropt = PVN::RevisionRegexpOption.new
      ropt.set_value val
      ropt.post_process nil, [ path ]
      act = ropt.value
      assert_equal exp, act, "val: #{val}; path: #{path}"
    end

    def test_post_process_middling
      assert_post_process '1887', '-7', '/Programs/wiquery/trunk'
    end

    def test_post_process_latest
      assert_post_process '1950', '-1', '/Programs/wiquery/trunk'
    end

    def test_post_process_oldest
      assert_post_process '412', '-163', '/Programs/wiquery/trunk'
    end

    def test_post_process_tagval_unconverted
      assert_post_process '-r7', '-r7', '/Programs/wiquery/trunk'
    end

    def test_post_process_tagrange_unconverted
      assert_post_process '-r7:177', '-r7:177', '/Programs/wiquery/trunk'
    end
  end
end
