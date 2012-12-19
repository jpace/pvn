#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/seek/command'
require 'pvn/seek/options'
require 'integration/tc'

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
      puts strio.string
      
      actlines = strio.string.split "\n"

      assert_equal explines, actlines

      $io = $stdout
      Dir.chdir orig_dir
    end

    def test_found
      expected = [
                  "[33mFirstFile.txt[0m -r[35m3[0m:[32m5[0m",
                  "0: [1mthis is the first line of the first file in the testbed.[0m"
                 ]

      assert_seek_command expected, %w{ this FirstFile.txt }
    end
  end
end
