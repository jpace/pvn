#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'integration/tc'
require 'pvn/pct/options'

module PVN::Pct
  class TestCase < PVN::IntegrationTestCase
    def assert_command cls, args, explines
      orig_dir = Dir.pwd
      
      Dir.chdir '/Programs/pvn/pvntestbed.pending'

      strio = StringIO.new

      $io = strio

      info "args: #{args}"

      opts = OptionSet.new
      info "opts: #{opts}"

      opts.process args

      cmd = cls.new opts
      info "cmd: #{cmd}"
      
      strio.close
      puts strio.string
      
      actlines = strio.string.split("\n")

      assert_arrays_equal explines, actlines

      $io = $stdout
      Dir.chdir orig_dir
    end
  end
end
