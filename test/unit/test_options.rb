require 'pvn/option/set'
require 'pvn/tc'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module PVN
  class TestOptionSet < Test::Unit::TestCase
    def test_option_entry
      # ce = OptionEntry.new(:somekey, '-x', { :default => "algo" })

      # assert_equal :somekey, ce.key
      # assert_equal '-x', ce.tag
      # assert_equal({ :default => "algo" }, ce.options)
    end
  end
end