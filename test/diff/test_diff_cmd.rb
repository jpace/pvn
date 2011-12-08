require 'test_helper'
require 'pvn/diff/diffcmd'

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

    def test_none
      # write ~/.pvn/config.rb and load it ...
      doc = DiffCommand.to_doc
      puts "doc: #{doc}".on_green
    end

    def test_no_change
      # 
    end

    def test_against_head
    end

    def test_between_two_revisions
      # diff -r 132:412
    end

    def test_change
      # diff -c 317
    end

    def test_revision_against_head
      # diff -r 317 (same as -r 317:HEAD)
    end

    def test_filter_known_type_java
      # diff --diff-cmd diffj Foo.java
    end

    def test_filter_unknown_type
      # diff foo.yaml
    end
  end
end
