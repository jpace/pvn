#!/usr/bin/ruby -w
# -*- ruby -*-

require 'integration/pvn/subcommands/diff/differ_tc'
require 'pvn/subcommands/diff/logpaths'
require 'pvn/revision'

module PVN::Subcommands::Diff
  class LogPathsTestCase < PVN::IntegrationTestCase
    def xxxtest_paths
      revision = PVN::RevisionRange.new '15', '16'
      paths = %w{ . }
      lps = LogPaths.new revision, paths
      assert_equal "foo", lps.entries
    end
  end
end
