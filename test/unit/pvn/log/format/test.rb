#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'svnx/log/entries'
require 'pvn/io/element'
require 'pvn/log/format'

require 'resources'

Log.level = Log::DEBUG

module PVN
  module Log
    class FormatTestCase < PVN::TestCase
      def test_default
        dir = PVN::IO::Element.new :local => '/Programs/wiquery/trunk'
        
        # dirlog = dir.log SVNx::LogCommandArgs.new(:limit => 5, :verbose => true)

        test_lines = Resources.instance.test_lines '/Programs/wiquery/trunk', "svn", "log", "-l", "15", "-v", "--xml"

        entries = SVNx::Log::Entries.new :xmllines => test_lines.join('')

        # assert_log_entry_equals entries[2], expdata

        info "entries: #{entries}"

        fmt = PVN::Log::Format.new
        entries.each_with_index do |entry, idx|
          fmtlines = fmt.format entry, idx, entries.size
          
          puts fmtlines
          puts '-' * 55
        end

        fmtlines = fmt.format entries[0], 0, nil
        explines = [
                    "\e[1m1950\e[0m      \e[1m-1\e[0m        \e[36m\e[1mjpace\e[0m\e[0m                    \e[35m\e[1m2011-12-05T12:41:52.385786Z\e[0m\e[0m",
                    "",
                    "\e[40m\e[37mTesting.\e[0m\e[0m",
                    "",
                    "    \e[33m/trunk/buildNumber.properties\e[0m"
                   ]

        assert_equal explines, fmtlines
      end
    end
  end
end
