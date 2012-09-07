#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/log/tc'
require 'svnx/log/entries'
require 'pvn/io/element'
require 'resources'

module PVN::IO::IOElement
  class LogTestCase ###$$$ < PVN::Log::TestCase
    def assert_log_entries_size expsize, dirlog
      assert_equal expsize, dirlog.entries.size
    end

    def assert_log_command exp_n_entries, localpath, args = Hash.new
      dir = PVN::IO::Element.new :local => localpath
      cmdargs = SVNx::LogCommandArgs.new args

      dirlog = dir.log cmdargs
      # info "dirlog: #{dirlog}".yellow
      dirlog.entries.each do |entry|
        # info "entry: #{entry}".blue
      end

      assert_log_entries_size exp_n_entries, dirlog
    end
    
    def test_options_none
      assert_log_command 163, Resources::WIQTR_PATH
    end
    
    def test_option_limit
      assert_log_command 15, Resources::WIQTR_PATH, :limit => 15
    end
  end
end
