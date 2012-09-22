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
      # puts strio.string

      actlines = strio.string.split("\n")

      assert_arrays_equal explines, actlines

      $io = $stdout
      Dir.chdir orig_dir
    end
    
    def xxxtest_local_to_head
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

    def xtest_revision_to_revision
      explines = Array.new

      assert_diff_command %w{ -r15:20 }, explines
    end
  end
end
