#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/diff/repository_differ'
require 'integration/pvn/diff/differ_tc'

module PVN::Diff
  class RepositoryDifferTestCase < DifferTestCase

    def create_differ opts
      RepositoryDiffer.new opts
    end
    
    def test_adds
      explines = Array.new

      explines << "Index: src/java/Alpha.java"
      explines << "==================================================================="
      explines << "--- src/java/Alpha.java	(revision 0)"
      explines << "+++ src/java/Alpha.java	(revision 16)"
      explines << "@@ -0,0 +1,6 @@"
      explines << "+package org.incava.pvntest;"
      explines << "+"
      explines << "+public class Alpha {"
      explines << "+    public Alpha() {"
      explines << "+    }"
      explines << "+}"
      explines << "Index: src/java/Bravo.java"
      explines << "==================================================================="
      explines << "--- src/java/Bravo.java	(revision 0)"
      explines << "+++ src/java/Bravo.java	(revision 16)"
      explines << "@@ -0,0 +1,10 @@"
      explines << "+/**"
      explines << "+ * This describes this interface."
      explines << "+ */"
      explines << "+interface Bravo "
      explines << "+{"
      explines << "+	/**"
      explines << "+	 * This describes this method."
      explines << "+	 */"
      explines << "+	public int size();"
      explines << "+}"

      assert_diff_command %w{ -r15:16 }, explines
    end

    def test_one_add_one_delete
      explines = Array.new

      explines << "Index: FifthFile.txt"
      explines << "==================================================================="
      explines << "--- FifthFile.txt	(revision 0)"
      explines << "+++ FifthFile.txt	(revision 7)"
      explines << "@@ -0,0 +1 @@"
      explines << "+uno"
      explines << "Index: SecondFile.txt"
      explines << "==================================================================="
      explines << "--- SecondFile.txt	(revision 6)"
      explines << "+++ SecondFile.txt	(revision 7)"
      explines << "@@ -1,4 +0,0 @@"
      explines << "-line one of file two."
      explines << "-# file two, line two"
      explines << "-# line three"
      explines << "-line four"

      assert_diff_command %w{ -r6:7 }, explines
    end

    def test_only_changes
      explines = Array.new

      explines << "Index: FirstFile.txt"
      explines << "==================================================================="
      explines << "--- FirstFile.txt	(revision 2)"
      explines << "+++ FirstFile.txt	(revision 3)"
      explines << "@@ -1,2 +1,3 @@"
      explines << " This is the first line of the first file in the testbed."
      explines << " This is the second line of the first file."
      explines << "+Third line here."
      explines << "Index: SecondFile.txt"
      explines << "==================================================================="
      explines << "--- SecondFile.txt	(revision 2)"
      explines << "+++ SecondFile.txt	(revision 3)"
      explines << "@@ -1,2 +1,3 @@"
      explines << " line one of file two."
      explines << "+file two, line two"
      explines << " "
      
      assert_diff_command %w{ -r2:3 }, explines
    end

    def test_multiple_changes
      explines = Array.new

      explines << "Index: FirstFile.txt"
      explines << "==================================================================="
      explines << "--- FirstFile.txt	(revision 1)"
      explines << "+++ FirstFile.txt	(revision 4)"
      explines << "@@ -1 +1,3 @@"
      explines << " This is the first line of the first file in the testbed."
      explines << "+This is the second line of the first file."
      explines << "+Third line here."
      explines << "Index: SecondFile.txt"
      explines << "==================================================================="
      explines << "--- SecondFile.txt	(revision 0)"
      explines << "+++ SecondFile.txt	(revision 4)"
      explines << "@@ -0,0 +1,3 @@"
      explines << "+line one of file two."
      explines << "+# file two, line two"
      explines << "+line three"
      explines << "Index: ThirdFile.tar.gz"
      explines << "==================================================================="
      explines << "Binary files ThirdFile.tar.gz	(revision 0) and ThirdFile.tar.gz	(revision 4) differ"

      assert_diff_command %w{ -r1:4 }, explines
    end

    # still broken
    def test_revision_against_working_copy
      explines = Array.new
      
      # -r20 means -r20:working_copy

      explines << "Index: FirstFile.txt"
      explines << "==================================================================="
      explines << "--- FirstFile.txt	(revision 22)"
      explines << "+++ FirstFile.txt	(working copy)"
      explines << "@@ -1,3 +1,4 @@"
      explines << " this is the second line of the first file."
      explines << "-third line here."
      explines << "+    third line here."
      explines << " fourth line this is."
      explines << "+this is the fifth line."
      explines << "Index: SecondFile.txt"
      explines << "==================================================================="
      explines << "--- SecondFile.txt	(revision 20)"
      explines << "+++ SecondFile.txt	(working copy)"
      explines << "@@ -1,4 +1,6 @@"
      explines << " line one of file two."
      explines << "+second line"
      explines << "+third line"
      explines << " line four"
      explines << " line five"
      explines << " line 6, Six, VI"
      explines << "Index: SeventhFile.txt"
      explines << "==================================================================="
      explines << "--- SeventhFile.txt	(revision 0)"
      explines << "+++ SeventhFile.txt	(revision 0)"
      explines << "@@ -0,0 +1 @@"
      explines << "+this is the 7th file."
      # this is wrong: this is a binary, and should be displayed as such:
      explines << "Index: archive/rubies.zip"
      explines << "==================================================================="
      explines << "Index: dirzero/SixthFile.txt"
      explines << "==================================================================="
      explines << "--- dirzero/SixthFile.txt	(revision 22)"
      explines << "+++ dirzero/SixthFile.txt	(working copy)"
      explines << "@@ -1,2 +0,0 @@"
      explines << "-line one."
      explines << "-line two."
      explines << "Index: src/ruby/charlie.rb"
      explines << "==================================================================="
      explines << "--- src/ruby/charlie.rb	(revision 20)"
      explines << "+++ src/ruby/charlie.rb	(working copy)"
      explines << "@@ -2,6 +2,7 @@"
      explines << " # -*- ruby -*-"
      explines << " "
      explines << " def charlie x"
      explines << "+  puts x"
      explines << " end"
      explines << " "
      explines << " charlie 1"
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

      assert_diff_command %w{ -r20 }, explines
    end
  end
end
