#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/tc'
require 'svnx/log/command'

module SVNx
  module Log
    class CommandArgsTestCase < SVNx::Log::TestCase

      def test_options_log_limit
        cmdargs = LogCommandArgs.new :limit => 6
        cmd = LogCommand.new :use_cache => true, :cmdargs => cmdargs
        assert_equal 'svn log --xml --limit 6', cmd.command_line.to_command
      end

      def test_options_verbose
        cmdargs = LogCommandArgs.new :verbose => true
        cmd = LogCommand.new :use_cache => true, :cmdargs => cmdargs
        assert_equal 'svn log --xml -v', cmd.command_line.to_command
      end
    end
  end
end
