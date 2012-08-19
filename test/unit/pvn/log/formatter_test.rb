#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'svnx/log/entries'
require 'pvn/io/element'
require 'pvn/log/formatter'

require 'resources'

Log.level = Log::DEBUG

module PVN; module Log; end; end

module PVN::Log
  class FormatTestCase < PVN::TestCase
    TEST_LINES = Resources.instance.test_lines '/Programs/wiquery/trunk', "svn", "log", "-l", "15", "-v", "--xml"
    ENTRIES = SVNx::Log::Entries.new :xmllines => TEST_LINES.join('')

    def show_all entries, from_head, from_tail
      ef = EntriesFormatter.new true, entries, from_head, from_tail
      puts ef.format
    end

    def assert_entry_format explines, entry, use_colors, idx, from_head, from_tail, total
      ef = EntryFormatter.new use_colors, entry, idx, from_head, from_tail, total

      fmtlines = ef.format
      assert_equal explines, fmtlines
    end

    def test_colors_from_head_not_from_tail_index_0
      entries = ENTRIES
      explines = [
                  "\e[1m1950\e[0m      \e[1m-1\e[0m        \e[36m\e[1mjpace\e[0m\e[0m                    \e[35m\e[1m2011-12-05T12:41:52.385786Z\e[0m\e[0m",
                  "",
                  "\e[37mTesting.\e[0m",
                  "",
                  "    \e[33m/trunk/buildNumber.properties\e[0m"
                 ]
      assert_entry_format explines, entries[0], true, 0, true, false, 15
    end

    def test_colors_from_head_not_from_tail_index_4
      entries = ENTRIES
      explines = [
                  "\e[1m1950\e[0m      \e[1m-5\e[0m        \e[36m\e[1mjpace\e[0m\e[0m                    \e[35m\e[1m2011-12-05T12:41:52.385786Z\e[0m\e[0m",
                  "",
                  "\e[37mTesting.\e[0m",
                  "",
                  "    \e[33m/trunk/buildNumber.properties\e[0m"
                 ]
      assert_entry_format explines, entries[0], true, 4, true, false, 15
    end

    def test_no_colors_from_head_from_tail_index_4
      entries = ENTRIES
      explines = [
                  "1950      -5   +10  jpace                    2011-12-05T12:41:52.385786Z",
                  "",
                  "Testing.",
                  "",
                  "    /trunk/buildNumber.properties"
                 ]
      assert_entry_format explines, entries[0], false, 4, true, true, 15
    end

    def test_colors_from_head_from_tail_index_4
      entries = ENTRIES
      explines = [
                  "\e[1m1950\e[0m      \e[1m-5\e[0m   \e[1m+10\e[0m  \e[36m\e[1mjpace\e[0m\e[0m                    \e[35m\e[1m2011-12-05T12:41:52.385786Z\e[0m\e[0m",
                  "",
                  "\e[37mTesting.\e[0m",
                  "",
                  "    \e[33m/trunk/buildNumber.properties\e[0m"
                 ]
      assert_entry_format explines, entries[0], true, 4, true, true, 15
    end

    def test_no_colors_from_head_not_from_tail_index_4
      entries = ENTRIES
      explines = [
                  "1950      -5        jpace                    2011-12-05T12:41:52.385786Z",
                  "",
                  "Testing.",
                  "",
                  "    /trunk/buildNumber.properties"
                 ]
      assert_entry_format explines, entries[0], false, 4, true, false, 15
    end

    def test_another
    end
  end
end
