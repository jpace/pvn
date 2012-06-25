require 'pvn/tc'
require 'pvn/log/logentry'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module PVN
  class TestLogEntry < PVN::TestCase
    include Loggable

    def test_entries
    end
  end
end
