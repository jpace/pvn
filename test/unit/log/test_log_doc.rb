require 'pvn/tc'
require 'pvn/log/logcmd'

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
