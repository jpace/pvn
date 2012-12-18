#!/usr/bin/ruby -w
# -*- ruby -*-

require 'integration/tc'
require 'resources'
require 'stringio'
require 'pvn/diff/command'

Log.level = Log::DEBUG

module PVN::Diff
  class TestCase < PVN::TestCase

    def assert_arrays_equal expected, actual
      (0 ... [ expected.size, actual.size ].max).each do |idx|
        assert_equal expected[idx], actual[idx]
      end
    end

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
      puts strio.string
      
      actlines = strio.string.split "\n"

      assert_arrays_equal explines, actlines

      $io = $stdout
      Dir.chdir orig_dir
    end

    def create_differ opts
      raise "not implemented for #{self.class}"
    end
  end
end
