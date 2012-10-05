#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'integration/pvn/pct/tc'
require 'pvn/pct/repository_differ'

module PVN::Pct
  class RepositoryDifferTest < TestCase
    def test_revision_to_working_copy
      explines = Array.new
      
      explines << "       3        5        2     66.7% SecondFile.txt"
      explines << "       3        5        2     66.7% total"
      
      assert_diff_command RepositoryDiffer, %w{ -r20 }, explines
    end
  end
end
