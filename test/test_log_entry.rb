require File.dirname(__FILE__) + '/test_helper.rb'

require 'rubygems'
require 'riel'
require 'pvn/log'
require 'mocklog'
require 'pvn_test'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module PVN
  class TestLogEntry < PVN::TestCase
    include Loggable

    def test_entries
    end
  end
end
