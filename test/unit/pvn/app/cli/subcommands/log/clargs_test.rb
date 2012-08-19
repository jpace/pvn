#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'pvn/app/cli/subcommands/log/clargs'
require 'pvn/app/cli/subcommands/log/options'

Log.level = Log::DEBUG

module PVN; module App; module Log; end; end; end

module PVN::App::Log
  class CmdLineArgsTest < PVN::TestCase
    def assert_command_line_args exp, args
      optset = PVN::App::CLI::Log::OptionSet.new 
      cmdline = PVN::App::Log::CmdLineArgs.new optset, args

      info "cmdline: #{cmdline}"
      assert_equal exp[:limit], cmdline.limit
      assert_equal exp[:revision].to_s, cmdline.revision.to_s
    end

    def test_default
      expdata = Hash.new
      expdata[:limit] = nil
      expdata[:path] = '.'
      assert_command_line_args expdata, Array.new
    end

    def test_limit
      expdata = Hash.new
      expdata[:limit] = 15
      expdata[:path] = '.'
      assert_command_line_args expdata, %w{ --limit 15 }
    end

    def test_revision_single
      expdata = Hash.new
      expdata[:limit] = nil
      expdata[:revision] = '500'
      expdata[:path] = '.'
      assert_command_line_args expdata, %w{ -r500 }
    end

    def test_revision_multi
      expdata = Hash.new
      expdata[:limit] = nil
      expdata[:revision] = '500:600'
      expdata[:path] = '.'
      assert_command_line_args expdata, %w{ -r500:600 }
    end

    def test_help
      expdata = Hash.new
      expdata[:limit] = nil
      expdata[:revision] = nil
      expdata[:path] = '.'
      expdata[:help] = true
      assert_command_line_args expdata, %w{ --help }
    end          

    def test_revision_relative
      expdata = Hash.new
      expdata[:limit] = nil
      expdata[:revision] = '1944'
      expdata[:path] = '/Programs/wiquery/trunk'
      assert_command_line_args expdata, %w{ -5 /Programs/wiquery/trunk }
    end
  end
end
