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
      def assert_revision_entry test_lines, exp_value, value
        rev = PVN::Revisionxxx::Entry.new :xmllines => test_lines && test_lines.join(''), :value => value
        assert_equal exp_value.to_s, rev.value
      end

      def test_normal
        test_lines = nil
        assert_revision_entry test_lines, 733, 733
        assert_revision_entry test_lines, 1907, 1907
        assert_revision_entry test_lines, 'HEAD', 'HEAD'
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

        assert_revision_entry test_lines, 733, 733
        assert_revision_entry test_lines, 1907, 1907
        assert_revision_entry test_lines, 1907, 1907
      end

      # def test_end
      #   class File
      #     def initialize args
      #       rev = args[:revision]
      #       reventry = Revision.new name, rev
      #       @revision = reventry.number
      #     end
      #   end

      #   dir = PVN::IO::File :name => "pom.xml", :revision => "-3"
      #   assert_equal 190, dir.revision
      # end
    end
  end
end
