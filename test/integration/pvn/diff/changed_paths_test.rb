#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/diff/changed_paths'
require 'integration/pvn/diff/tc'

module PVN::Diff
  class ChangedPathsTestCase < TestCase

    def assert_diff paths, revision, whitespace, explines
      orig_dir = Dir.pwd
      Dir.chdir '/Programs/pvn/pvntestbed.pending'
      strio = StringIO.new
      $io = strio

      cp = ChangedPaths.new paths
      cp.diff_revision_to_working_copy revision, whitespace
      
      strio.close
      if Logue::Log.verbose
        puts strio.string
      end

      actlines = strio.string.split "\n"

      if false
        puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        puts actlines
        puts "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"

        puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        puts explines
        puts "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
      end

      assert_arrays_equal explines, actlines

      $io = $stdout
      Dir.chdir orig_dir
    end

    def test_revision_against_working_copy
      explines = Array.new

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

      ### $$$ this revision might not be zero in svn-land:
      explines << "Index: archive/rubies.zip"
      explines << "==================================================================="
      explines << "Binary files archive/rubies.zip\t(revision 0) and archive/rubies.zip\t(revision working_copy) differ"

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
      
      # -r20 means -r20:working_copy

      revision = SVNx::Revision::Range.new 20, nil
      whitespace = false
      paths = %w{ . }

      assert_diff paths, revision, whitespace, explines
    end
  end
end
