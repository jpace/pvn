#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/log/tc'
require 'svnx/log/entries'
require 'svnx/log/xml/xmllog'
require 'pvn/io/element'

module PVN
  module IOxxx
    module IOElement
      class LogTestCase < PVN::Log::TestCase
        def assert_log_entries_size expsize, dirlog
          assert_equal expsize, dirlog.entries.size
        end
        
        def test_options_none
          dir = PVN::IOxxx::Element.new :local => '/Programs/wiquery/trunk'

          dirlog = dir.log
          # info "dirlog: #{dirlog}".yellow
          dirlog.entries.each do |entry|
            # info "entry: #{entry}".blue
          end

          assert_log_entries_size 163, dirlog
        end
        
        def test_option_limit
          dir = PVN::IOxxx::Element.new :local => '/Programs/wiquery/trunk'
          cmdargs = SVNx::LogCommandArgs.new :limit => 15

          dirlog = dir.log cmdargs
          # info "dirlog: #{dirlog}".yellow
          dirlog.entries.each do |entry|
            # info "entry: #{entry}".blue
          end

          assert_log_entries_size 15, dirlog
        end
      end
    end
  end
end
