#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/tc'
require 'svnx/log/command'

Log::level = Log::DEBUG

module SVNx
  module Log
    class CommandLineTestCase < SVNx::Log::TestCase
      include Loggable

      def test_something
        cmdline = LogCommandLine.new
        info "cmdline: #{cmdline}".blue
      end
    end
  end
end
