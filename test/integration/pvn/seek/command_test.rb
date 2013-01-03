#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/seek/command'
require 'pvn/seek/options'
require 'integration/tc'
require 'rainbow'

module PVN::Seek
  class CommandTest < PVN::IntegrationTestCase
    def assert_command_no_color explines, args
      assert_command_output Command, explines, %w{ --no-color } + args
    end

    def assert_command explines, args
      assert_command_output Command, explines, args
    end

    def test_added_found
      expected = [
                  "FirstFile.txt -r5:13",
                  "3: fourth line this is."
                 ]
      assert_command_no_color expected, %w{ this FirstFile.txt }
    end

    def test_added_not_found
      expected = [
                  "not found in revisions: 1 .. 13"
                 ]
      assert_command expected, %w{ that FirstFile.txt }
    end

    def test_added_found_color
      expected = [
                  "[33mFirstFile.txt[0m -r5:13",
                  "3: fourth line this is."
                 ]
      assert_command expected, %w{ this FirstFile.txt }
    end

    def test_removed_found
      expected = [
                  "SecondFile.txt -r13:15",
                  "3: # line three"
                 ]
      assert_command_no_color expected, %w{ -M three SecondFile.txt }
    end

    def test_removed_not_found
      expected = [
                  "not removed in revisions: 13 .. 22"
                 ]
      assert_command expected, [ '-M', 'line four', 'SecondFile.txt' ]
    end

    def test_removed_found_color
      expected = [
                  "[33mSecondFile.txt[0m -r13:15",
                  "3: # line three"
                 ]
      assert_command expected, %w{ -M three SecondFile.txt }
    end

    def test_added_in_most_recent_revision
      expected = [
                  "SecondFile.txt -r20:22",
                  "3: third line"
                 ]
      assert_command_no_color expected, %w{ third SecondFile.txt }
    end

    def test_added_multiple_matches
      expected = [
                  "SecondFile.txt -r20:22",
                  "2: second line",
                  "3: third line",
                 ]
      assert_command_no_color expected, [ 'd line', 'SecondFile.txt' ]
    end

    def test_added_in_current_and_previous_revisions
      expected = [
                  "FirstFile.txt -r1:2",
                  "2: This is the second line of the first file."
                 ]
      assert_command_no_color expected, [ 'This', 'FirstFile.txt' ]
    end

    def test_added_between_revisions
      expected = [
                  "SecondFile.txt -r15:13", "3: # line three"
                 ]      
      assert_command_no_color expected, [ '-r1:18', 'th', 'SecondFile.txt' ]
    end

    def test_removed_in_current_and_previous_revisions
      expected = [
                  "SecondFile.txt -r13:15",
                  "2: # file two, line two",
                  "3: # line three"
                 ]
      assert_command_no_color expected, [ '--removed', 'line', 'SecondFile.txt' ]
    end
  end
end
