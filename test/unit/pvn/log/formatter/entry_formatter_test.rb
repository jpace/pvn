#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'svnx/log/entries'
require 'pvn/io/element'
require 'pvn/log/formatter/entry_formatter'

require 'resources'

module PVN; module Log; end; end

module PVN::Log
  class EntryFormatTestCase < PVN::TestCase
    TEST_LINES = Resources::PT_LOG_R19_1_V.readlines
    ENTRIES = SVNx::Log::Entries.new :xmllines => TEST_LINES

    def show_all entries, from_head, from_tail
      ef = EntriesFormatter.new true, entries, from_head, from_tail
      puts ef.format
    end

    def assert_format explines, entry, use_colors, idx, from_head, from_tail, total
      ef = EntryFormatter.new use_colors, entry, idx, from_head, from_tail, total

      fmtlines = ef.format
      # assert_equal explines, fmtlines
      (0 .. [ explines.length, fmtlines.length ].max).each do |lnum|
        assert_equal explines[lnum], fmtlines[lnum], "line: #{lnum}"
      end
    end

    def test_colors_from_head_not_from_tail_index_0
      entries = ENTRIES
      explines = [
                  "\e[1m19\e[0m        \e[1m-1\e[0m        \e[36m\e[1mLili von Shtupp\e[0m\e[0m          \e[35m\e[1m2012-09-16T14:24:07.913759Z\e[0m\e[0m",
                  "",
                  "\e[37m\e[0m",
                  "",
                  "    \e[33m/SecondFile.txt\e[0m"
                 ]
      assert_format explines, entries[0], true, 0, true, false, 15
    end

    def test_colors_from_head_not_from_tail_index_3
      entries = ENTRIES
      explines = [
                  "\e[1m16\e[0m        \e[1m-4\e[0m        \e[36m\e[1mBuddy Bizarre\e[0m\e[0m            \e[35m\e[1m2012-09-16T14:07:30.329525Z\e[0m\e[0m",
                  "",
                  "\e[37mCUT! What in the hell do you think you're doing here? This is a closed set.\e[0m",
                  "",
                  "\e[1m    \e[32m/src/java\e[0m\e[0m",
                  "    \e[32m/src/java/Alpha.java\e[0m",
                  "    \e[32m/src/java/Bravo.java\e[0m"
                 ]
      assert_format explines, entries[3], true, 3, true, false, 15
    end

    def test_no_colors_from_head_from_tail_index_3
      entries = ENTRIES
      explines = [
                  "16        -4   +11  Buddy Bizarre            2012-09-16T14:07:30.329525Z",
                  "",
                  "CUT! What in the hell do you think you're doing here? This is a closed set.",
                  "",
                  "    /src/java",
                  "    /src/java/Alpha.java",
                  "    /src/java/Bravo.java"
                 ]
      assert_format explines, entries[3], false, 3, true, true, 15
    end

    def test_colors_from_head_from_tail_index_3
      entries = ENTRIES
      explines = [
                  "\e[1m16\e[0m        \e[1m-4\e[0m   \e[1m+11\e[0m  \e[36m\e[1mBuddy Bizarre\e[0m\e[0m            \e[35m\e[1m2012-09-16T14:07:30.329525Z\e[0m\e[0m",
                  "",
                  "\e[37mCUT! What in the hell do you think you're doing here? This is a closed set.\e[0m",
                  "",
                  "\e[1m    \e[32m/src/java\e[0m\e[0m",
                  "    \e[32m/src/java/Alpha.java\e[0m",
                  "    \e[32m/src/java/Bravo.java\e[0m"
                 ]
      assert_format explines, entries[3], true, 3, true, true, 15
    end

    def test_no_colors_from_head_not_from_tail_index_3
      entries = ENTRIES
      explines = [
                  "16        -4        Buddy Bizarre            2012-09-16T14:07:30.329525Z",
                  "",
                  "CUT! What in the hell do you think you're doing here? This is a closed set.",
                  "",
                  "    /src/java",
                  "    /src/java/Alpha.java",
                  "    /src/java/Bravo.java"
                 ]
      assert_format explines, entries[3], false, 3, true, false, 15
    end
  end
end
