#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/diff/local_differ'
require 'integration/pvn/diff/differ_tc'

Log.level = Log::DEBUG

module PVN::Subcommands::Diff
  class LocalDifferTestCase < DifferTestCase

    def create_differ opts
      LocalDiffer.new opts
    end

    def get_explines comparing_whitespace
      explines = Array.new

      explines << "Index: FirstFile.txt"
      explines << "==================================================================="
      explines << "--- FirstFile.txt	(revision 22)"
      explines << "+++ FirstFile.txt	(working copy)"
      explines << "@@ -1,3 +1,4 @@"
      explines << " this is the second line of the first file."

      if comparing_whitespace
        explines << "-third line here."
        explines << "+    third line here."
      else
        explines << " third line here."
      end

      explines << " fourth line this is."
      explines << "+this is the fifth line."
      explines << "Index: SeventhFile.txt"
      explines << "==================================================================="
      explines << "--- SeventhFile.txt	(revision 0)"
      explines << "+++ SeventhFile.txt	(revision 0)"
      explines << "@@ -0,0 +1 @@"
      explines << "+this is the 7th file."
      explines << "Index: dirzero/SixthFile.txt"
      explines << "==================================================================="
      explines << "--- dirzero/SixthFile.txt	(revision 22)"
      explines << "+++ dirzero/SixthFile.txt	(working copy)"
      explines << "@@ -1,2 +0,0 @@"
      explines << "-line one."
      explines << "-line two."
      explines << "Index: src/ruby/dog.rb"
      explines << "==================================================================="
      explines << "--- src/ruby/dog.rb	(revision 0)"
      explines << "+++ src/ruby/dog.rb	(revision 0)"
      explines << "@@ -0,0 +1,7 @@"
      explines << "+#!/usr/bin/ruby -w"
      explines << "+# -*- ruby -*-"
      explines << "+"
      explines << "+require 'rubygems'"
      explines << "+require 'riel'"
      explines << "+"
      explines << "+puts \"hello, world\""

      explines
    end
    
    def test_default
      assert_diff_command %w{ }, get_explines(true)
    end
    
    def test_no_whitespace
      assert_diff_command %w{ -w }, get_explines(false)
    end
  end
end
