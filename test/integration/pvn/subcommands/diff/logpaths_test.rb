#!/usr/bin/ruby -w
# -*- ruby -*-

require 'integration/pvn/subcommands/diff/differ_tc'
require 'pvn/subcommands/diff/logpaths'
require 'pvn/revision'

module PVN::Subcommands::Diff
  class LogPathsTestCase < PVN::IntegrationTestCase
    def assert_log_path expname, exprevisions, explogentrypath, expsvninfo, lps, idx
      logpath = lps.elements[idx]
      msg = "element[#{idx}]"
      assert_equal expname, logpath.name, msg
      assert_equal exprevisions, logpath.revisions, msg
      # 
    end
      
    def test_paths
      revision = PVN::RevisionRange.new '15', '16'
      paths = %w{ . }
      lps = LogPaths.new revision, paths
      assert_equal 3, lps.elements.size
      
      assert_log_path "/SecondFile.txt",      [ "15" ], nil, nil, lps, 0
      assert_log_path "/src/java/Bravo.java", [ "16" ], nil, nil, lps, 1
      assert_log_path "/src/java/Alpha.java", [ "16" ], nil, nil, lps, 2
    end
  end
end
