require 'pvn/tc'
require 'pvn/log/logcmd'

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
