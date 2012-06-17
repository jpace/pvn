#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn_test'
require 'pvn/svn/log/entry'
require 'pvn/svn/log/logdata'

module PVN
  module SVN
    class TestCaseLog < PVN::TestCase
      include Loggable
      
      def assert_entry_equals entry, expdata
        assert_equals expdata[0], entry.revision
        assert_equals expdata[1], entry.author
        assert_equals expdata[2], entry.date
        assert_equals expdata[3], entry.message
        entry.paths.each_with_index do |path, idx|
          info path.inspect.yellow
          assert_equals expdata[4 + idx][:kind], path.kind
          assert_equals expdata[4 + idx][:action], path.action
          assert_equals expdata[4 + idx][:name], path.name
        end
      end      
    end
  end
end
