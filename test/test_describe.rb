require File.dirname(__FILE__) + '/test_helper.rb'

require 'rubygems'
require 'riel'
require 'pvn/describe'
require 'mocklog'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module PVN
  class TestDescribe < Test::Unit::TestCase
    include Loggable

    def uses fname
    end
    
    def setup
      # @mockexec = MockExecutor.new
    end

    def assert_describe_command exp, cmdargs = nil
      origargs = cmdargs && cmdargs.dup
      assert_equal exp, DescribeCommand.new(:execute => false, :command_args => cmdargs, :executor => @mockexec).command, "arguments: " + origargs.to_s
    end

    def test_one_revision
      # @todo this

      # assert_describe_command nil, nil
    end
  end
end
