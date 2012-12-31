#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/seek/command'
require 'pvn/seek/options'
require 'integration/tc'
require 'rainbow'

# produce colorized output, even when redirecting to a file:
Sickill::Rainbow.enabled = true

module PVN::Seek
  class CommandTest < PVN::IntegrationTestCase
    def assert_seek_command_no_color explines, args
      assert_command_output Command, explines, %w{ --no-color } + args
    end

    def assert_seek_command explines, args
      assert_command_output Command, explines, args
    end

    def test_added_found
      expected = [
                  "[33mFirstFile.txt[0m -r[35m5[0m:[32m13[0m",
                  "3: [1mfourth line this is.[0m"
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
                  "FirstFile.txt -r5:13",
                  "3: fourth line this is."
                 ]

      assert_seek_command_no_color expected, %w{ this FirstFile.txt }
    end

    def test_no_color_added_not_found
      expected = [
                  "not found in revisions: 1 .. 13"
                 ]

      assert_seek_command_no_color expected, %w{ that FirstFile.txt }
    end

    def test_no_color_removed_found
      expected = [
                  "SecondFile.txt -r13:15",
                  "3: # line three"
                 ]
      
      assert_seek_command_no_color expected, %w{ -M three SecondFile.txt }
    end

    def test_added_in_most_recent_revision
      expected = [
                  "[33mSecondFile.txt[0m -r[35m20[0m:[32m22[0m",
                  "3: [1mthird line[0m"
                 ]
      
      assert_seek_command expected, %w{ third SecondFile.txt }
    end

    def test_added_multiple_matches
      expected = [
                  "SecondFile.txt -r20:22",
                  "2: second line",
                  "3: third line",
                 ]
      
      assert_seek_command_no_color expected, [ 'd line', 'SecondFile.txt' ]
    end

    def xxxtest_added_between_revisions
      expected = [
                  "not removed in revisions: 13 .. 22"
                 ]
      
      assert_seek_command expected, [ '-r15', '-r22', '--no-color', 'line f', 'SecondFile.txt' ]
    end
  end
end
