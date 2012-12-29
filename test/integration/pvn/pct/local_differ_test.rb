#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/pct/local_differ'
require 'integration/pvn/pct/tc'

module PVN::Pct
  class LocalDifferTest < TestCase
    def test_working_copy
      explines = Array.new

      explines << "       3        4        1     33.3% FirstFile.txt"
      explines << "       3        4        1     33.3% total"

      assert_command LocalDiffer, explines, %w{ }
    end
  end
end
