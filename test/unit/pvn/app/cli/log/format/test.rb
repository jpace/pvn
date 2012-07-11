#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/tc'
require 'svnx/log/entries'
require 'pvn/io/element'
require 'pvn/app/cli/log/format'

Log.level = Log::DEBUG

module PVN
  module App
    module CLI
      module Log
        class FormatTestCase < PVN::TestCase
          def test_default
            dir = PVN::IO::Element.new :local => '/Programs/wiquery/trunk'
            
            dirlog = dir.log SVNx::LogCommandArgs.new(:limit => 5, :verbose => true)

            fmt = PVN::App::Log::Format.new
            dirlog.entries.each_with_index do |entry, idx|
              fmtlines = fmt.format entry, idx, dirlog.entries.size
              
              puts fmtlines
              puts '-' * 55
            end

            fmtlines = fmt.format dirlog.entries[0], 0, nil
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
  end
end
