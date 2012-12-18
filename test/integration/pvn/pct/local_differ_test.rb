#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'integration/pvn/pct/tc'
require 'pvn/pct/local_differ'
require 'pvn/pct/options'

module PVN::Pct
  class LocalDifferTest < TestCase
    def test_working_copy
      explines = Array.new

      explines << "       3        4        1     33.3% FirstFile.txt"
      explines << "       3        4        1     33.3% total"

      assert_command LocalDiffer, %w{ }, explines
    end
  end
end
