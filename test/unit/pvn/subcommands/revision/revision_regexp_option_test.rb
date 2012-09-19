#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'pvn/subcommands/revision/revision_regexp_option'
require 'pvn/subcommands/revision/tc'
require 'resources'

module PVN
  class MockRevisionRegexpOption < RevisionRegexpOption
    include MockBaseRevisionOption
  end

  class RevisionRegexpOptionTest < BaseRevisionOptionTestCase
    def create_option
      PVN::MockRevisionRegexpOption.new
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
      assert_revision_option_raises '-20'
    end

    def test_post_process_middling
      assert_post_process '13', '-7'
    end

    def test_post_process_latest
      assert_post_process '19', '-1'
    end

    def test_post_process_oldest
      assert_post_process '1', '-19'
    end

    def test_post_process_tagval
      assert_post_process '7', '-r7'
    end

    def test_post_process_tagrange
      assert_post_process '7:17', '-r7:17'
    end

    def test_post_process_absolute_middling
      assert_post_process '11', '11'
    end
  end
end
