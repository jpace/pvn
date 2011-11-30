require File.dirname(__FILE__) + '/test_helper.rb'

require 'rubygems'
require 'riel'
require 'pvn/log'
require 'mocklog'
require 'pvn_cmd_test'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module PVN
  class TestLog < CommandTestCase
    include Loggable

    def assert_log_command exp, cmdargs = nil
      origargs = cmdargs && cmdargs.dup
      assert_equal exp, LogCommand.new(:execute => false, :command_args => cmdargs, :use_cache => false).command, "arguments: " + origargs.to_s
    end

    def test_revision_re
      assert_match LogCommand::LOG_REVISION_LINE, "r61 | dhimuxrb | 2011-11-04 06:37:36 -0400 (Fri, 04 Nov 2011) | 1 line"
      assert_match LogCommand::LOG_REVISION_LINE, "r1053 | pxjrmir | 2011-11-09 17:46:29 -0500 (Wed, 09 Nov 2011) | 2 lines"
      assert_match LogCommand::LOG_REVISION_LINE, "r1053 | pxjrmir-jkjkl | 2011-11-09 17:46:29 -0500 (Wed, 09 Nov 2011) | 2 lines"
      assert_no_match LogCommand::LOG_REVISION_LINE, "r1053 pxjrmir | 2011-11-09 17:46:29 -0500 (Wed, 09 Nov 2011) | 2 lines"
    end

    def test_command_basic
      assert_log_command "svn log -l 5"
      assert_log_command "svn log -l 10", %w{ -l 10 }
      assert_log_command "svn log -l 10 foo", %w{ -l 10 foo }
      assert_log_command "svn log -l 5 foo", %w{ foo }
    end

    def test_command_nolimit
      assert_log_command "svn log foo", %w{ --no-limit foo }
      assert_log_command "svn log foo", %w{ --nolimit foo }
      assert_log_command "svn log", %w{ --no-limit }
      assert_log_command "svn log", %w{ --nolimit }
    end

    def test_command_using_unconverted_revision
      assert_log_command "svn log -r 11", %w{ -r 11 }
      assert_log_command "svn log -r 11", %w{ -l 10 -r 11 }
    end

    def test_command_using_negative_revision
      assert_log_command "svn log -r 1947", %w{ -r -1 }
      assert_log_command "svn log -r 1945", %w{ -l 10 -r -3 }
      assert_log_command "svn log -r 1720", %w{ -l 10 -r -17 }
    end

    def test_command_with_positive_revision
      # a revision without a limit is just that entry.
      assert_log_command "svn log -r 412", %w{ -r +1 }
    end

    def test_command_with_implied_revision
      assert_log_command "svn log -r 412", %w{ +1 }
      assert_log_command "svn log -r 1947", %w{ -1 }
      assert_log_command "svn log -r 1945", %w{ -3 }
      assert_log_command "svn log -r 1720", %w{ -17 }
    end
  end
end
