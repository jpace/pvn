#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'svnx/log/command'
require 'rexml/document'

module SVNx
  module Log
    class TestCase < PVN::TestCase
      include Loggable

      def test_lines
        IO.readlines("/proj/org/incava/pvn/test/resources/Programs_wiquery__svn_log_-l_15_--xml")
      end

      def test_lines_no_limit
        IO.readlines("/proj/org/incava/pvn/test/resources/Programs_wiquery__svn_log_--xml")
      end

      def test_lines_no_author
        IO.readlines("/proj/org/incava/pvn/test/resources/Programs_wiquery__svn_log_-r1_--xml")
      end

      def test_lines_empty_message
        IO.readlines("/proj/org/incava/pvn/test/resources/Programs_wiquery__svn_log_-r1748_--xml")
      end

      def find_subelement_by_name elmt, name
        subelmt = elmt.elements.detect { |el| el.name == name }
        subelmt ? subelmt.get_text.to_s : nil
      end

      def assert_log_entry_equals entry, expdata
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
