#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/log/tc'
require 'svnx/log/log'
require 'svnx/log/xml/xmllog'
require 'svnx/log/tc'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module PVN
  module App
    module CLI
      module Log
        module Format
          class ColorsTestCase < PVN::Log::TestCase
      
            def xxx_test_none
              raise "implement this"
            end
          end
        end
      end
    end
  end
end
