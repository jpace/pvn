#!/usr/bin/ruby -w
# -*- ruby -*-

require 'integration/tc'
require 'resources'
require 'stringio'
require 'pvn/diff/command'

module PVN::Diff
  class TestCase < PVN::IntegrationTestCase
    def assert_diff_command diffcls, args, explines
      orig_dir = Dir.pwd
      
      Dir.chdir '/Programs/pvn/pvntestbed.pending'

      strio = StringIO.new

      $io = strio

      info "args: #{args}"

      opts = OptionSet.new
      info "opts: #{opts}"

      opts.process args

      differ = diffcls.new opts
      info "differ: #{differ}"
      
      strio.close
      if Log.verbose
        puts strio.string
      end
      
      actlines = strio.string.split "\n"

      assert_arrays_equal explines, actlines

      $io = $stdout
      Dir.chdir orig_dir
    end
  end
end
