require 'pvn/tc'
require 'pvn/log/logcmd'
require 'pvn/log/logentry'
require 'pvn_cmd_test'

module PVN
  class TestLogCommand < PVN::CommandTestCase
    include Loggable

    def assert_log_command exp, cmdargs = nil
      origargs = cmdargs && cmdargs.dup
      assert_equal exp, LogCommand.new(:execute => false, :command_args => cmdargs, :use_cache => false).command, "arguments: " + origargs.to_s
    end

    def test_revision_re
      assert_match Log::SVN_LOG_SUMMARY_LINE_RE, "r61 | dhimuxrb | 2011-11-04 06:37:36 -0400 (Fri, 04 Nov 2011) | 1 line"
      assert_match Log::SVN_LOG_SUMMARY_LINE_RE, "r1053 | pxjrmir | 2011-11-09 17:46:29 -0500 (Wed, 09 Nov 2011) | 2 lines"
      assert_match Log::SVN_LOG_SUMMARY_LINE_RE, "r1053 | pxjrmir-jkjkl | 2011-11-09 17:46:29 -0500 (Wed, 09 Nov 2011) | 2 lines"
      assert_no_match Log::SVN_LOG_SUMMARY_LINE_RE, "r1053 pxjrmir | 2011-11-09 17:46:29 -0500 (Wed, 09 Nov 2011) | 2 lines"
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
    end

    def test_command_using_unconverted_revision_revision_overrides_limit
      assert_log_command "svn log -r 11", %w{ -l 10 -r 11 }
    end

    def test_command_using_negative_revision_only_revision_specified
      assert_log_command "svn log -r 1950", %w{ -r -1 }
      assert_log_command "svn log -r 1947", %w{ -r -2 }
    end

    def test_command_using_negative_revision_log_limit_specified
      assert_log_command "svn log -r 1946", %w{ -l 10 -r -3 }
      assert_log_command "svn log -r 1947", %w{ -l 10 -r -2 }
    end

    def test_command_using_negative_revision_log_limit_specified_out_of_range
      assert_log_command "svn log -r 1721", %w{ -l 10 -r -17 }
    end

    def test_command_with_positive_revision
      # a revision without a limit is just that entry.
      assert_log_command "svn log -r 412", %w{ -r +1 }
    end

    def test_command_with_implied_revision
      assert_log_command "svn log -r 412", %w{ +1 }
      # assert_log_command "svn log -r 1950", %w{ -1 }
      # assert_log_command "svn log -r 1946", %w{ -3 }
      # assert_log_command "svn log -r 1721", %w{ -17 }
    end

    LOG_SEP_LINE = "------------------------------------------------------------------------"

    def test_default_output
      lc = LogCommand.new Hash.new
      output = lc.output

      # the last 5 entries happen to be four lines apart, with only one line of
      # comment text each.
      [ 0, 4, 8, 12, 16, 20 ].each do |lnum|
        assert_equal LOG_SEP_LINE, output[lnum].chomp, "log entry separator line"
      end

      # @todo - extend the tests for output
    end

    def test_default_entries
      lc = LogCommand.new Hash.new

      entries = lc.entries
      info "entries: #{entries}"
      
      assert_equal 5, entries.length, "number of entries for default log command"
    end

    def test_verbose_entries
      lc = LogCommand.new :command_args => %w{ -v }
      
      entries = lc.entries
      info "entries: #{entries}"
      
      assert_equal 5, entries.length, "number of entries for default log command, verbose"

      entries.each do |entry|
        info "entry: #{entry}"
        entry.write true
      end
    end

    def test_log_direct_invoke
      lc = LogCommand.new :fromdate => Date.new(2010, 9, 18), :todate => Date.new(2010, 9, 22), :limit => nil
      # lc.run Array.new

      entries = lc.entries
      info "entries: #{entries}"
      
      assert_equal 6, entries.length, "number of entries for log direct invoke"

      entries.each do |entry|
        info "entry: #{entry}"
        entry.write true
      end
    end
  end
end
