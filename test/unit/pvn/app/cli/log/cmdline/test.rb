#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/log/tc'
require 'svnx/log/entries'
require 'pvn/io/element'
require 'pvn/app/cli/log/cmdline'

Log.level = Log::DEBUG

module PVN
  module App
    module Log
      class CmdLineArgsTest < PVN::Log::TestCase
        def assert_command_line_args explimit, args
          cmdline = PVN::App::Log::CmdLineArgs.new args
          info "cmdline: #{cmdline}".red
          assert_equal explimit, cmdline.limit
        end

        def test_default
          assert_command_line_args nil, Array.new
        end

        def test_limit
          assert_command_line_args 15, %w{ --limit 15 }
        end
      end
    end
  end
end
