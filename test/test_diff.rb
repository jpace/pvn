require File.dirname(__FILE__) + '/test_helper.rb'

require 'rubygems'
require 'riel'
require 'pvn/diff/command'
# require 'mockdiff'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module PVN
  class TestDiff < Test::Unit::TestCase
    include Loggable

    def uses fname
      # @mle.file = Pathname.new(File.dirname(__FILE__) + '/files/' + fname).expand_path
    end
    
    def setup
      # @mle = MockDiffExecutor.new
    end

    def assert_diff_command exp, cmdargs = nil
      origargs = cmdargs && cmdargs.dup
      assert_equal exp, DiffCommand.new(:execute => false, :command_args => cmdargs, :executor => @mle).command, "arguments: " + origargs.to_s
    end

    def assert_diff_command_mock exp, cmdargs = nil
      origargs = cmdargs && cmdargs.dup
      assert_equal exp, DiffCommand.new(:execute => false, :command_args => cmdargs, :executor => @mle).command, "arguments: " + origargs.to_s
    end

    def xtest_documentation
      doc = DiffCommand.to_doc
      puts "doc: #{doc}".on_green
    end

    def test_default
      assert_diff_command 'svn diff --diff-cmd /proj/org/incava/pvn/bin/pvndiff', %w{ }
    end

    def test_no_diff_command
      assert_diff_command 'svn diff', %w{ --no-diffcmd }
      assert_diff_command 'svn diff', %w{ --no-diff-cmd }
    end
  end
end
