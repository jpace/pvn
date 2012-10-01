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
    def xxxtest_revision_against_working_copy
      explines = Array.new
      
      # -r20 means -r20:working_copy

      assert_diff_command %w{ -r20 }, explines
    end
  end
end
