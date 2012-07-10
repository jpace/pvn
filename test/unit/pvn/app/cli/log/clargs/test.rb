#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/tc'
require 'pvn/app/cli/log/clargs'

Log.level = Log::DEBUG

module PVN
  module App
    module Log
      class CmdLineArgsTest < PVN::TestCase
        def assert_command_line_args exp, args
          cmdline = PVN::App::Log::CmdLineArgs.new args
          info "cmdline: #{cmdline}".red
          assert_equal exp[:limit], cmdline.limit
          assert_equal exp[:revision], cmdline.revision.to_s
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

        def test_revision
          expdata = Hash.new
          expdata[:limit] = nil
          expdata[:revision] = '500:600'
          expdata[:path] = '.'
          assert_command_line_args expdata, %w{ -r500:600 }
        end
      end
    end
  end
end
