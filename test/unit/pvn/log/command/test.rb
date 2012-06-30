#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/log/tc'
require 'svnx/log/log'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module PVN
  module Log
    module Commandxxx
      class TestCase < PVN::Log::TestCase
        include Loggable
        
      end
    end
  end
end
