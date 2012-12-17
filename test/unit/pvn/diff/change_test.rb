#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'pvn/diff/change'

module PVN::Diff
  class ChangeTestCase < PVN::TestCase
    def create_change revision, action
      Change.new revision, action
    end

    def assert_change_revision exprevision, revision
      prev = create_change revision, "added"
      assert_equal exprevision, prev.revision
    end

    def assert_change_action expaction, action
      prev = create_change "0", action
      assert_equal expaction, prev.action
    end

    def test_init_revision_string
      assert_change_revision "0", "0"
    end

    def test_init_revision_integer
      assert_change_revision "0", 0
    end

    def test_init_action_long_string
      assert_change_action SVNx::Action.new(:added), "added"
    end

    def test_init_action_short_string
      assert_change_action SVNx::Action.new(:deleted), "D"
    end

    def test_init_action_symbol
      assert_change_action SVNx::Action.new(:modified), :modified
    end
  end
end
