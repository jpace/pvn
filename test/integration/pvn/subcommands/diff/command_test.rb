#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'pvn/subcommands/diff/command'
require 'resources'
require 'stringio'

Log.level = Log::DEBUG

module PVN::Subcommands::Diff
  class CommandTest < PVN::TestCase

    def assert_arrays_equal expected, actual
      (0 ... [ expected.size, actual.size ].max).each do |idx|
        assert_equal expected[idx], actual[idx]
      end
    end

    def assert_diff_command args, explines
      orig_dir = Dir.pwd
      
      Dir.chdir '/Programs/pvn/pvntestbed.pending'

      strio = StringIO.new

      $io = strio

      info "args: #{args}"

      dc = Command.new args
      info "dc: #{dc}".yellow
      
      strio.close
      puts strio.string
      
      actlines = strio.string.split("\n")

      assert_arrays_equal explines, actlines

      $io = $stdout
      Dir.chdir orig_dir
    end
    
    def test_local_to_head
      explines = Array.new

      explines << "Index: FirstFile.txt"
      explines << "==================================================================="
      explines << "--- FirstFile.txt	(revision 22)"
      explines << "+++ FirstFile.txt	(working copy)"
      explines << "@@ -1,3 +1,4 @@"
      explines << " this is the second line of the first file."
      explines << " third line here."
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

      assert_diff_command %w{ }, explines
    end

    def test_revision_to_revision_adds
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

    def test_revision_to_revision_one_add_one_delete
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

    def test_revision_to_revision_only_changes
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

    def test_revision_to_revision_multiple_changes
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
  end
end
