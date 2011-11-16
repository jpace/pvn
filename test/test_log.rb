require File.dirname(__FILE__) + '/test_helper.rb'

require 'rubygems'
require 'riel'
require 'pvn/log'
require 'mocklog'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module PVN
  class TestLog < Test::Unit::TestCase
    include Loggable

    def uses fname
      @mle.file = Pathname.new(File.dirname(__FILE__) + '/files/' + fname).expand_path
    end
    
    def setup
      @mle = MockLogExecutor.new
    end

    def assert_log_command exp, cmdargs = nil
      origargs = cmdargs && cmdargs.dup
      assert_equal exp, LogCommand.new(:execute => false, :command_args => cmdargs, :executor => @mle).command, "arguments: " + origargs.to_s
    end

    def assert_log_command_mock exp, cmdargs = nil
      origargs = cmdargs && cmdargs.dup
      assert_equal exp, LogCommand.new(:execute => false, :command_args => cmdargs, :executor => @mle).command, "arguments: " + origargs.to_s
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
      assert_log_command "svn log foo", %w{ --no-limit foo }
      assert_log_command "svn log foo", %w{ --nolimit foo }
      assert_log_command "svn log", %w{ --no-limit }
      assert_log_command "svn log", %w{ --nolimit }
    end

    def test_command_using_unconverted_revision
      assert_log_command "svn log -l 5 -r 11", %w{ -r 11 }
      assert_log_command "svn log -l 10 -r 11", %w{ -l 10 -r 11 }
    end

    def test_command_using_converted_revision
      uses "svn/ant/core/src/limit50.txt"

      assert_log_command_mock "svn log -l 5 -r 1199931", %w{ -r -1 }
      assert_log_command_mock "svn log -l 10 -r 1199922", %w{ -l 10 -r -3 }
      assert_log_command_mock "svn log -l 10 -r 1153485", %w{ -l 10 -r -17 }
    end
  end
end
