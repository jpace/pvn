require File.dirname(__FILE__) + '/test_helper.rb'

require 'rubygems'
require 'riel'
require 'stringio'
require 'pvn/log'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module PVN
  class TestLogDoc < Test::Unit::TestCase
    include Loggable

    def test_documentation
      strio = StringIO.new
      LogCommand.to_doc strio
      puts "strio: #{strio.string}".green

      
    end
  end
end
