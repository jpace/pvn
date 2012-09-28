#!/usr/bin/ruby -w
# -*- ruby -*-

require 'integration/pvn/subcommands/diff/differ_tc'
require 'pvn/subcommands/diff/log_paths'
require 'pvn/revision'

module PVN::Subcommands::Diff
  class LogPathsTestCase < PVN::IntegrationTestCase
    def setup
      @orig_dir = Dir.pwd      
      Dir.chdir '/Programs/pvn/pvntestbed.pending'
    end

    def teardown
      Dir.chdir @orig_dir
    end

    def assert_log_path expname, exprevisions, explogentrypath, expurl, logpaths, idx
      logpath = logpaths[idx]
      msg = "element[#{idx}]"
      assert_equal expname, logpath.name, msg
      assert_equal exprevisions, logpath.revisions, msg
    end
      
    def test_revision_to_revision
      revision = PVN::Revision::Range.new '15', '16'
      paths = %w{ . }
      logpaths = LogPaths.new revision, paths
      assert_equal 3, logpaths.size
      
      assert_log_path "/SecondFile.txt",      [ "15" ], nil, nil, logpaths, 0
      assert_log_path "/src/java/Bravo.java", [ "16" ], nil, nil, logpaths, 1
      assert_log_path "/src/java/Alpha.java", [ "16" ], nil, nil, logpaths, 2
    end
  end
end
