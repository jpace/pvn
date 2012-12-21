#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/seek/command'
require 'pvn/seek/options'
require 'integration/tc'
require 'rainbow'

Sickill::Rainbow.enabled = true

module PVN::Seek
  class CommandTest < PVN::TestCase
    def assert_seek_command explines, args
      orig_dir = Dir.pwd
      
      Dir.chdir '/Programs/pvn/pvntestbed.pending'

      strio = StringIO.new

      $io = strio

      info "args: #{args}"

      # opts = OptionSet.new
      # info "opts: #{opts}"

      # opts.process args

      seek = Command.new args
      info "seek: #{seek}"
      
      strio.close
      puts "......................................................."
      puts strio.string
      puts "......................................................."
      
      actlines = strio.string.split "\n"

      assert_equal explines, actlines

      $io = $stdout
      Dir.chdir orig_dir
    end

    def test_added_found
      expected = [
                  "[33mFirstFile.txt[0m -r[35m3[0m:[32m5[0m",
                  "1: [1mthis is the first line of the first file in the testbed.[0m"
                 ]

      assert_seek_command expected, %w{ this FirstFile.txt }
    end

    def test_added_not_found
      expected = [
                  "not found in revisions: 1 .. 13"
                 ]

      assert_seek_command expected, %w{ that FirstFile.txt }
    end

    def test_removed_found
      expected = [
                  "[33mSecondFile.txt[0m -r[35m13[0m:[32m15[0m",
                  "3: [1m# line three[0m"
                 ]
      
      assert_seek_command expected, %w{ -M three SecondFile.txt }
    end

    def test_removed_not_found
      expected = [
                  "not removed in revisions: 13 .. 22"
                 ]
      
      assert_seek_command expected, [ '-M', 'line four', 'SecondFile.txt' ]
    end

    def test_no_color_added_found
      expected = [
                  "FirstFile.txt -r3:5",
                  "1: this is the first line of the first file in the testbed."
                 ]

      assert_seek_command expected, %w{ --no-color this FirstFile.txt }
    end

    def test_no_color_added_not_found
      expected = [
                  "not found in revisions: 1 .. 13"
                 ]

      assert_seek_command expected, %w{ --no-color that FirstFile.txt }
    end

    def test_no_color_removed_found
      expected = [
                  "SecondFile.txt -r13:15",
                  "3: # line three"
                 ]
      
      assert_seek_command expected, %w{ -M --no-color three SecondFile.txt }
    end

    def test_added_in_most_recent_revision
      expected = [
                  "[33mSecondFile.txt[0m -r[35m20[0m:[32m22[0m",
                  "3: [1mthird line[0m"
                 ]
      
      assert_seek_command expected, %w{ third SecondFile.txt }
    end

    def xxx_test_added_between_revisions
      expected = [
                  "not removed in revisions: 13 .. 22"
                 ]
      
      assert_seek_command expected, [ '-r15', '-r22', '--no-color', 'line f', 'SecondFile.txt' ]
    end
  end
end
