#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'pvn/diff/path'

module PVN::Diff
  class PathTestCase < PVN::TestCase
    def create_path name, revision, action, url
      Path.new name, revision, action, url
    end

    def assert_path_name expname, name
      logpath = create_path name, "0", "added", "file:///var/svn/repo"
      assert_equal expname, logpath.name
    end

    def assert_path_url expurl, url
      logpath = create_path "File.txt", "0", "deleted", url
      assert_equal expurl, logpath.url
    end

    def test_init_name
      assert_path_name "File.txt", "File.txt"
    end

    def test_init_url
      assert_path_url "file:///var/svn/repo", "file:///var/svn/repo"
    end

    def test_add_revision
      path = create_path "File.txt", "0", :added, "file:///var/svn/repo"
      assert_equal 1, path.path_revisions.size
      path.add_revision "1", :modified
      assert_equal 2, path.path_revisions.size
    end
  end
end
