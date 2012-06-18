#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn_test'
require 'pvn/svn/log/command'

module PVN
  module SVN
    class TestLogCommand < PVN::TestCase
      include Loggable

      def test_run
        Dir.chdir '/Programs/wiquery/trunk'
        
        cmd = LogCommand.new({ :use_cache => false })
        info "cmd: #{cmd}"
        
        cmd = LogCommand.new({ :use_cache => true })
        info "cmd: #{cmd}"
        
        # info "cmd.output: #{cmd.output}".blue
      end
    end
  end
end
