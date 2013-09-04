#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'svnx/log/command'
require 'rexml/document'
require 'logue/loggable'

module PVN
  class IntegrationTestCase < PVN::TestCase
    include Logue::Loggable

    PT_DIRNAME = '/Programs/pvn/pvntestbed.from'

    def setup
      @cache_dir = ENV['PVN_CACHE_DIR'] || '/tmp/pvncache.testing'
      remove_cache_dir
      
      super

      @origdir = Dir.pwd
      Dir.chdir '/Programs/pvn/pvntestbed.pending'
    end

    def teardown
      remove_cache_dir
      Dir.chdir @origdir
      super
    end

    def remove_cache_dir
      pn = Pathname.new @cache_dir
      pn.rmtree if pn.exist?
    end

    def assert_cache_dir_exists expected
      pn = Pathname.new @cache_dir
      assert_equal expected, pn.exist?
    end

    def find_subelement_by_name elmt, name
      subelmt = elmt.elements.detect { |el| el.name == name }
      subelmt ? subelmt.get_text.to_s : nil
    end

    def assert_arrays_equal expected, actual
      # assert_equal expected, actual
      (0 ... [ expected.size, actual.size ].max).each do |idx|
        assert_equal expected[idx], actual[idx], "line[#{idx}]"
      end
    end

    def assert_command_block(explines, &blk)
      orig_dir = Dir.pwd
      
      Dir.chdir '/Programs/pvn/pvntestbed.pending'

      strio = StringIO.new

      $io = strio

      blk.call

      strio.close

      if Logue::Log.verbose
        puts "......................................................."
        puts strio.string
        puts "......................................................."
      end
      
      actlines = strio.string.split("\n")

      assert_arrays_equal explines, actlines

      $io = $stdout
      Dir.chdir orig_dir
    end

    def assert_command_output cmdcls, explines, args
      assert_command_block(explines) do
        cmdcls.new args
      end
    end

    def assert_command_option_output cmdcls, optcls, args, explines
      assert_command_block(explines) do
        info "args: #{args}"
        
        opts = optcls.new
        info "opts: #{opts}"
        
        opts.process args
        
        cmd = cmdcls.new opts
        info "cmd: #{cmd}"
      end
    end
  end
end
