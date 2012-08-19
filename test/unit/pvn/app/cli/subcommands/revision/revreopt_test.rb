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
  end
end
