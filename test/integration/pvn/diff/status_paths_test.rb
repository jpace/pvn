#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/diff/status_paths'
require 'pvn/revision/range'
require 'pp'
require 'integration/tc'

module PVN::Diff
  class StatusPathsTestCase < PVN::IntegrationTestCase
    def assert_status_path exp_name, exp_nchanges, exp_url, statuspaths, idx
      statuspath = statuspaths[idx]
      msg = "element[#{idx}]"
      assert_equal exp_name,     statuspath.name,         msg
      assert_equal exp_nchanges, statuspath.changes.size, msg
    end
      
    def test_to_working_copy
      # revision doesn't matter:
      revision = PVN::Revision::Range.new '20'
      paths = %w{ . }
      statuspaths = StatusPaths.new revision, paths
      expnames = [
               "FirstFile.txt",
               "SeventhFile.txt",
               "dirzero/SixthFile.txt",
               "src/ruby/dog.rb"
              ]
      assert_equal 4, expnames.size

      expnames.each_with_index do |expname, idx|
        assert_status_path expname, 1, nil, statuspaths, idx
      end
    end
  end
end
