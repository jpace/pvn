require File.dirname(__FILE__) + '/../test_helper.rb'

require 'rubygems'
require 'riel'
require 'pvn/commands/cachecmd'
require 'pvn/commands/log'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module PVN
  class TestLogCommand < Test::Unit::TestCase
    include Loggable

    def test_entry
      entry = PVN::Log::Entry.new :date => "somedate"
      info "entry: #{entry}"
      info "entry.date: #{entry.date}"
    end
  end
end
