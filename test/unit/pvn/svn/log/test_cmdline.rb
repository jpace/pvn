#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn_test'
require 'pvn/svn/log/command'

Log::level = Log::DEBUG

module PVN
  module SVN
    class TestLogCommandLine < PVN::TestCase
      include Loggable

      def test_something
        cmdline = LogCommandLine.new
        info "cmdline: #{cmdline}".blue
      end
    end
  end
end
