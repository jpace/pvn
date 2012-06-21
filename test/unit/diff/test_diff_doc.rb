require 'test_helper'
require 'stringio'
require 'pvn/diff/diffcmd'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module PVN
  class TestDiffDoc < Test::Unit::TestCase
    include Loggable

    def test_documentation
      strio = StringIO.new
      DiffCommand.to_doc strio
      puts "strio: #{strio.string}".green      
    end
  end
end
