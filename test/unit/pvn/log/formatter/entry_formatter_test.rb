#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'svnx/log/entries'
require 'pvn/io/element'
require 'pvn/log/formatter/entry_formatter'

module PVN; module Log; end; end

module PVN::Log
  class EntryFormatTestCase < PVN::TestCase
    TEST_LINES = Resources::PT_LOG_R19_1_V.readlines
    ENTRIES = SVNx::Log::Entries.new :xmllines => TEST_LINES

    def show_all entries, from_head, from_tail
      ef = EntriesFormatter.new true, entries, from_head, from_tail
      puts ef.format
    end

    def assert_format explines, use_colors, idx, from_head, from_tail
      total = 15
      entry = ENTRIES[idx]
      ef = EntryFormatter.new use_colors, entry, idx, from_head, from_tail, total

      fmtlines = ef.format
      # assert_equal explines, fmtlines
      (0 .. [ explines.length, fmtlines.length ].max).each do |lnum|
        assert_equal explines[lnum], fmtlines[lnum], "line: #{lnum}"
      end
    end

    def test_colors_from_head_not_from_tail_index_0
      # 2012-09-16T14:24:07.913759Z
      explines = [
                  "\e[1m19\e[0m        \e[1m-1\e[0m        \e[1m\e[36mLili von Shtupp\e[0m          \e[1m\e[35m12-09-16 14:24:07\e[0m",
                  "",
                  "\e[37m\e[0m",
                  "",
                  "    \e[33m/SecondFile.txt\e[0m"
                 ]
      assert_format explines, true, 0, true, false
    end

    def test_colors_from_head_not_from_tail_index_3
      explines = [
                  "\e[1m16\e[0m        \e[1m-4\e[0m        \e[1m\e[36mBuddy Bizarre\e[0m            \e[1m\e[35m12-09-16 14:07:30\e[0m",
                  "",
                  "\e[37mCUT! What in the hell do you think you're doing here? This is a closed set.\e[0m",
                  "",
                  "\e[1m    \e[32m/src/java\e[0m",
                  "    \e[32m/src/java/Alpha.java\e[0m",
                  "    \e[32m/src/java/Bravo.java\e[0m"
                 ]
      assert_format explines, true, 3, true, false
    end

    def test_no_colors_from_head_from_tail_index_3
      explines = [
                  "16        -4   +11  Buddy Bizarre            12-09-16 14:07:30",
                  "",
                  "CUT! What in the hell do you think you're doing here? This is a closed set.",
                  "",
                  "    /src/java",
                  "    /src/java/Alpha.java",
                  "    /src/java/Bravo.java"
                 ]
      assert_format explines, false, 3, true, true
    end

    def test_colors_from_head_from_tail_index_3
      # was 2012-09-16T14:07:30.329525Z, svn's format
      explines = [
                  "\e[1m16\e[0m        \e[1m-4\e[0m   \e[1m+11\e[0m  \e[1m\e[36mBuddy Bizarre\e[0m            \e[1m\e[35m12-09-16 14:07:30\e[0m",
                  "",
                  "\e[37mCUT! What in the hell do you think you're doing here? This is a closed set.\e[0m",
                  "",
                  "\e[1m    \e[32m/src/java\e[0m",
                  "    \e[32m/src/java/Alpha.java\e[0m",
                  "    \e[32m/src/java/Bravo.java\e[0m"
                 ]
      assert_format explines, true, 3, true, true
    end

    def test_no_colors_from_head_not_from_tail_index_3
      explines = [
                  "16        -4        Buddy Bizarre            12-09-16 14:07:30",
                  "",
                  "CUT! What in the hell do you think you're doing here? This is a closed set.",
                  "",
                  "    /src/java",
                  "    /src/java/Alpha.java",
                  "    /src/java/Bravo.java"
                 ]
      assert_format explines, false, 3, true, false
    end
  end
end
