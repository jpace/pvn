#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/diff/status_paths'
require 'pvn/revision/range'
require 'pp'

module PVN::Diff
  class StatusPathsTestCase < PVN::IntegrationTestCase
    def assert_status_path exp_name, exp_nrevisions, exp_url, statuspaths, idx
      statuspath = statuspaths[idx]
      msg = "element[#{idx}]"
      assert_equal exp_name, statuspath.name, msg
      assert_equal exp_nrevisions, statuspath.path_revisions.size, msg
    end
      
    def test_to_working_copy
      # revision doesn't matter:
      revision = PVN::Revision::Range.new '20'
      paths = %w{ . }
      statuspaths = StatusPaths.new revision, paths
      pp statuspaths
      assert_equal 4, statuspaths.size
      
      assert_status_path "/FirstFile.txt",         1, nil, statuspaths, 0
      assert_status_path "/src/ruby/dog.rb",       1, nil, statuspaths, 1
      assert_status_path "/SeventhFile.txt",       1, nil, statuspaths, 2
      assert_status_path "/dirzero/SixthFile.txt", 1, nil, statuspaths, 3
    end
  end
end
