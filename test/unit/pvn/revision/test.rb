#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'svnx/log/entries'
require 'pvn/revision/entry'

require 'resources'

Log.level = Log::DEBUG

module PVN
  module Revisionxxx
    class TestCase < PVN::TestCase
      def assert_revision_entry test_lines, exp_number, number
        rev = PVN::Revisionxxx::Entry.new :xmllines => test_lines.join(''), :number => number
        assert_equal exp_number, rev.number
      end

      def test_default
        # dir = PVN::IO::Element.new :local => '/Programs/wiquery/trunk'        
        # dirlog = dir.log SVNx::LogCommandArgs.new(:limit => 5, :verbose => true)

        test_lines = Resources.instance.test_lines '/Programs/wiquery/trunk', "svn", "log", "--xml", "pom.xml"

        logentries = SVNx::Log::Entries.new :xmllines => test_lines.join('')

        # assert_log_entry_equals logentries[2], expdata

        info "logentries: #{logentries}"

        logentries.each do |logentry|
          info "logentry: #{logentry}"
          info "logentry.revision: #{logentry.revision}"
        end

        # rev = PVN::Revisionxxx::Entry.new logentries, 733
        assert_revision_entry test_lines, 733, 733
        assert_revision_entry test_lines, 1907, 1907
      end
    end
  end
end
