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
        cmdline = LogCommandLine.new true
        info "cmdline: #{cmdline}".blue
        assert_equal PVN::Environment.instance.cache_dir, cmdline.cache_dir
        assert cmdline.use_cache?
      end
    end
  end
end
