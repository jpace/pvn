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
            dirlog.entries.each do |entry|
              fmtlines = fmt.format entry
              
              puts fmtlines
              puts '-' * 55
            end

            fmtlines = fmt.format dirlog.entries[0]
            explines = [
                        "\e[33m1950\e[0m      \e[36mjpace\e[0m                    \e[35m2011-12-05T12:41:52.385786Z\e[0m",
                        "",
                        "\e[40m\e[33m\e[1mTesting.\e[0m\e[0m\e[0m",
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
