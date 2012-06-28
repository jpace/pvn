#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn_test'
require 'svnx/log/entry'
require 'svnx/log/logdata'

module PVN
  module SVN
    class TestCaseLog < PVN::TestCase
      include Loggable
      
      def assert_entry_equals entry, expdata
        assert_equal expdata[0], entry.revision
        assert_equal expdata[1], entry.author
        assert_equal expdata[2], entry.date
        assert_equal expdata[3], entry.message
        entry.paths.each_with_index do |path, idx|
          info path.inspect.yellow
          assert_equal expdata[4 + idx][:kind], path.kind
          assert_equal expdata[4 + idx][:action], path.action
          assert_equal expdata[4 + idx][:name], path.name
        end
      end      
    end
  end
end
