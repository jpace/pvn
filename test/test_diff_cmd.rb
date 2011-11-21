require File.dirname(__FILE__) + '/test_helper.rb'

require 'rubygems'
require 'riel'
require 'pvn/diff'

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
  end
end
