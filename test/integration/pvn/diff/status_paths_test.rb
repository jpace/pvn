#!/usr/bin/ruby -w
# -*- ruby -*-

require 'integration/pvn/diff/differ_tc'
require 'pvn/diff/status_paths'
require 'pvn/revision/range'

module PVN::Diff
  class StatusPathsTestCase < PVN::IntegrationTestCase
    def assert_status_path expname, exprevisions, expstatusentrypath, expurl, statuspaths, idx
      statuspath = statuspaths[idx]
      msg = "element[#{idx}]"
      assert_equal expname, statuspath.name, msg
      assert_equal exprevisions, statuspath.revisions, msg      
    end
      
    def test_to_working_copy
      revision = PVN::Revision::Range.new '20'
      paths = %w{ . }
      statuspaths = StatusPaths.new revision, paths
      pp statuspaths
      assert_equal 4, statuspaths.size
      
      assert_status_path "/FirstFile.txt",         [ "22" ], nil, nil, statuspaths, 0
      assert_status_path "/src/ruby/dog.rb",       [ "0" ],  nil, nil, statuspaths, 1
      assert_status_path "/SeventhFile.txt",       [ "0" ],  nil, nil, statuspaths, 2
      assert_status_path "/dirzero/SixthFile.txt", [ "22" ], nil, nil, statuspaths, 3
    end
  end
end
