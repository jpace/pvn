#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'pvn/subcommands/revision/revision_regexp_option'
require 'pvn/subcommands/revision/tc'

module PVN
  class RevisionRegexpOptionTest < BaseRevisionOptionTestCase
    def create_option
      PVN::RevisionRegexpOption.new
    end

    def set_value opt, val
      opt.set_value val
    end

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

    def test_out_of_range
      assert_raises(RuntimeError) do 
        ropt = PVN::RevisionRegexpOption.new
        ropt.process [ '-164' ]
        ropt.post_process nil, [ '/Programs/wiquery/trunk' ]
      end
    end

    def test_post_process_middling
      assert_post_process '1887', '-7'
    end

    def test_post_process_latest
      assert_post_process '1950', '-1'
    end

    def test_post_process_oldest
      assert_post_process '412', '-163'
    end

    def test_post_process_tagval
      assert_post_process '7', '-r7'
    end

    def test_post_process_tagrange
      assert_post_process '7:177', '-r7:177'
    end

    def test_post_process_absolute_middling
      assert_post_process '1887', '1887'
    end
  end
end
