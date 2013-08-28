#!/usr/bin/ruby -w
# -*- ruby -*-

require 'integration/tc'
require 'pvn/diff/log_paths'
require 'svnx/revision/range'

module PVN::Diff
  class LogPathsTestCase < PVN::IntegrationTestCase
    def assert_log_path exp_name, exp_nchanges, expurl, logpaths, idx
      logpath = logpaths[idx]
      msg = "element[#{idx}]"
      assert_equal exp_name, logpath.name, msg
      assert_equal exp_nchanges, logpath.changes.size, msg
    end
      
    def test_revision_to_revision
      revision = SVNx::Revision::Range.new '15', '16'
      paths = %w{ . }
      logpaths = LogPaths.new revision, paths
      exppaths = [
                  "/SecondFile.txt",
                  "/src/java/Alpha.java",
                  "/src/java/Bravo.java"
                 ]
      
      assert_equal exppaths.size, logpaths.size
      exppaths.each_with_index do |exppath, idx|
        assert_log_path exppath, 1, nil, logpaths, idx
      end
      
      assert_log_path "/SecondFile.txt",      1, nil, logpaths, 0
      assert_log_path "/src/java/Alpha.java", 1, nil, logpaths, 1
      assert_log_path "/src/java/Bravo.java", 1, nil, logpaths, 2
    end
  end
end
