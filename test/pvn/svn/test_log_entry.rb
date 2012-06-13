#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn_test'
require 'pvn/svn/log/entry'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module PVN
  module SVN
    class TestLogEntry < PVN::TestCase
      include Loggable

      TEST_LINES = Array.new
      TEST_LINES << "------------------------------------------------------------------------"
      TEST_LINES << "r757 | reiern70 | 2011-04-08 00:11:00 -0400 (Fri, 08 Apr 2011) | 4 lines"
      TEST_LINES << ""
      TEST_LINES << "additional fix for "
      TEST_LINES << ""
      TEST_LINES << "http://code.google.com/p/wiquery/issues/detail?id=160"
      TEST_LINES << ""
      TEST_LINES << "------------------------------------------------------------------------"
      TEST_LINES << "r756 | hielke.hoeve@gmail.com | 2011-04-07 02:57:15 -0400 (Thu, 07 Apr 2011) | 2 lines"
      TEST_LINES << ""
      TEST_LINES << "jquery 1.5.2 and jquery ui 1.8.11."
      TEST_LINES << ""
      TEST_LINES << "------------------------------------------------------------------------"
      TEST_LINES << "r755 | hielke.hoeve@gmail.com | 2011-04-06 11:02:17 -0400 (Wed, 06 Apr 2011) | 1 line"
      TEST_LINES << ""
      TEST_LINES << "merge from trunk to 1.5: r754."
      TEST_LINES << "------------------------------------------------------------------------"
      TEST_LINES << "r754 | hielke.hoeve@gmail.com | 2011-04-06 10:36:59 -0400 (Wed, 06 Apr 2011) | 2 lines"
      TEST_LINES << ""
      TEST_LINES << "jquery 1.5.2 and jquery ui 1.8.11."
      TEST_LINES << ""
      TEST_LINES << "------------------------------------------------------------------------"

      def assert_log_re_match line, expdata
        md = Entry::LOG_SUMMARY_RE.match line

        assert_not_nil md
        (1 .. 7).each do |idx|
          assert_equals expdata[idx - 1], md[idx], "field: #{idx}"
        end

        md
      end

      def assert_entry_match md, expdata
        entry = Entry.new({ :revision => md[1], :user => md[2], :date => md[3], :time => md[4], :tz => md[5], :dtg => md[6], :nlines => md[7] })

        assert_equals expdata[0], entry.revision
        assert_equals expdata[1], entry.user
        assert_equals expdata[2], entry.date
        assert_equals expdata[3], entry.time
        assert_equals expdata[4], entry.tz
        assert_equals expdata[5], entry.dtg
        assert_equals expdata[6], entry.nlines
        assert_equals expdata[7], entry.comment
        assert_equals expdata[8], entry.files
      end
      
      def test_multiple_lines_no_comment_no_files
        expdata = '757', 'reiern70', '2011-04-08', '00:11:00', '-0400', 'Fri, 08 Apr 2011', '4'
        
        md = assert_log_re_match TEST_LINES[1], expdata
        
        assert_entry_match md, expdata
      end

      def test_single_line_no_comment_no_files
        expdata = '755', 'hielke.hoeve@gmail.com', '2011-04-06', '11:02:17', '-0400', 'Wed, 06 Apr 2011', '1'
        
        md = assert_log_re_match TEST_LINES[13], expdata
        assert_entry_match md, expdata
      end
    end
  end
end
