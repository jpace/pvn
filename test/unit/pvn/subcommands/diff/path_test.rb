#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'pvn/subcommands/diff/path'
require 'svnx/action'

module PVN::Subcommands::Diff
  # an entry with a name, revision, logentry.path, and svninfo
  class PathTestCase < PVN::TestCase
    def create_path name, revision, action, url
      Path.new name, revision, action, url
    end

    def assert_path_name expname, name
      logpath = create_path name, "0", "added", "file:///var/svn/repo"
      assert_equal expname, logpath.name
    end

    def assert_path_revision exprevisions, revisions
      logpath = create_path "File.txt", revisions, "added", "file:///var/svn/repo"
      assert_equal exprevisions, logpath.revisions
    end

    def assert_path_action expaction, action
      logpath = create_path "File.txt", "0", action, "file:///var/svn/repo"
      assert_equal expaction, logpath.action
    end

    def assert_path_url expurl, url
      logpath = create_path "File.txt", "0", "deleted", url
      assert_equal expurl, logpath.url
    end

    def test_init_name
      assert_path_name "File.txt", "File.txt"
    end

    def test_init_revision_string
      assert_path_revision [ "0" ], "0"
    end

    def test_init_revision_integer
      assert_path_revision [ "0" ], 0
    end

    def test_init_revision_array_strings
      assert_path_revision [ "0", "14" ], [ "0", "14" ]
    end

    def test_init_revision_array_integers
      assert_path_revision [ "0", "14" ], [ 0, 14 ]
    end

    def test_init_action_long_string
      assert_path_action SVNx::Action.new(:added), "added"
    end

    def test_init_action_short_string
      assert_path_action SVNx::Action.new(:deleted), "D"
    end

    def test_init_action_symbol
      assert_path_action SVNx::Action.new(:modified), :modified
    end

    def test_init_url
      assert_path_url "file:///var/svn/repo", "file:///var/svn/repo"
    end
  end
end
