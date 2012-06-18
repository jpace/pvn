#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn_test'
require 'pvn/svn/log/command'

module PVN
  module SVN
    class TestLogCommandLine < PVN::TestCase
      include Loggable

      def test
        cmdline = LogCommandLine.new
        info "cmdline: #{cmdline}".blue
        assert_equals "/tmp/cache_dir_for_log_command", cmdline.cache_dir
        assert cmdline.use_cache?
      end
    end
  end
end
