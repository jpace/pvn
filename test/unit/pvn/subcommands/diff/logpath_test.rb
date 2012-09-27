#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'pvn/subcommands/diff/logpath'
require 'svnx/action'

module PVN::Subcommands::Diff
  # an entry with a name, revision, logentry.path, and svninfo
  class LogPathTestCase < PVN::TestCase
    def create_logpath name, revision, action, url
      LogPath.new name, revision, action, url
    end

    def assert_logpath_name expname, name
      logpath = create_logpath name, "0", "added", "file:///var/svn/repo"
      assert_equal expname, logpath.name
    end

    def assert_logpath_revision exprevisions, revisions
      logpath = create_logpath "File.txt", revisions, "added", "file:///var/svn/repo"
      assert_equal exprevisions, logpath.revisions
    end

    def assert_logpath_action expaction, action
      logpath = create_logpath "File.txt", "0", action, "file:///var/svn/repo"
      assert_equal expaction, logpath.action
    end

    def assert_logpath_url expurl, url
      logpath = create_logpath "File.txt", "0", "deleted", url
      assert_equal expurl, logpath.url
    end

    def test_init_name
      assert_logpath_name "File.txt", "File.txt"
    end

    def test_init_revision_string
      assert_logpath_revision [ "0" ], "0"
    end

    def test_init_revision_integer
      assert_logpath_revision [ "0" ], 0
    end

    def test_init_revision_array_strings
      assert_logpath_revision [ "0", "14" ], [ "0", "14" ]
    end

    def test_init_revision_array_integers
      assert_logpath_revision [ "0", "14" ], [ 0, 14 ]
    end

    def test_init_action_long_string
      assert_logpath_action SVNx::Action.new(:added), "added"
    end

    def test_init_action_short_string
      assert_logpath_action SVNx::Action.new(:deleted), "D"
    end

    def test_init_action_symbol
      assert_logpath_action SVNx::Action.new(:modified), :modified
    end

    def test_init_url
      assert_logpath_url "file:///var/svn/repo", "file:///var/svn/repo"
    end
  end
end
