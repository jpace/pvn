#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'pvn/diff/path_revision'

module PVN::Diff
  ### $$$ yes, a lot of this is the same as Path; there is overlap as Path
  ### changes to a collection of PathRevisions
  class PathRevisionTestCase < PVN::TestCase
    def create_pathrev revision, action
      PathRevision.new revision, action
    end

    def assert_pathrev_revision exprevision, revision
      prev = create_pathrev revision, "added"
      assert_equal exprevision, prev.revision
    end

    def assert_pathrev_action expaction, action
      prev = create_pathrev "0", action
      assert_equal expaction, prev.action
    end

    def test_init_revision_string
      assert_pathrev_revision "0", "0"
    end

    def test_init_revision_integer
      assert_pathrev_revision "0", 0
    end

    def test_init_action_long_string
      assert_pathrev_action SVNx::Action.new(:added), "added"
    end

    def test_init_action_short_string
      assert_pathrev_action SVNx::Action.new(:deleted), "D"
    end

    def test_init_action_symbol
      assert_pathrev_action SVNx::Action.new(:modified), :modified
    end
  end
end
