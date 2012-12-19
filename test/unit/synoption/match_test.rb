#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'synoption/match'

module PVN
  class MatchTestCase < TestCase
    def assert_match exp, matcher, arg
      assert_equal exp, matcher.match?(arg), "arg: #{arg}"
    end

    def assert_matches exp, matcher, *args
      args.each do |arg|
        assert_match exp, matcher, arg
      end
    end

    def test_exact
      matcher = OptionExactMatch.new '-t', 'tagname'
      assert_matches true,  matcher, '-t', '--tagname'
      assert_matches false, matcher, '-T', '--tag-name', '--no-tagname', '--notagname'
    end

    def test_negative_string
      matcher = OptionNegativeMatch.new '-T'
      assert_matches true,  matcher, '-T'
      assert_matches false, matcher, '-t'
    end

    def test_negative_regexp
      matcher = OptionNegativeMatch.new %r{^\-\-no\-?tagname$}
      assert_matches true,  matcher, '--no-tagname', '--notagname'
      assert_matches false, matcher, '-t', '--non-tagname' '--nontagname'
    end

    def test_negative_multiple
      matcher = OptionNegativeMatch.new %r{^\-\-no\-?tagname$}, '-T'
      assert_matches true,  matcher, '-T', '--no-tagname', '--notagname'
      assert_matches false, matcher, '-t', '--tagname'
    end

    def assert_match_not_nil matcher, arg
      assert_not_nil matcher.match?(arg), "arg: #{arg}"
    end

    def assert_matches_not_nil matcher, *args
      args.each do |arg|
        assert_match_not_nil matcher, arg
      end
    end

    def test_regexp_match
      matcher = OptionRegexpMatch.new %r{^--tag-?name$}
      assert_matches_not_nil matcher, '--tagname', '--tag-name'
      assert_matches nil,    matcher, '--tagnames' '--tag--name'
    end
  end
end
