#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/pct/repository_differ'
require 'integration/pvn/pct/tc'

module PVN::Pct
  class RepositoryDifferTest < TestCase
    def test_revision_to_working_copy
      explines = Array.new
      
      explines << "       3        5        2     66.7% SecondFile.txt"
      explines << "       3        5        2     66.7% total"
      
      assert_command RepositoryDiffer, %w{ -r20 }, explines
    end

    def test_revision_to_revision
      explines = Array.new

      explines << "       3        7        4    133.3% SecondFile.txt"
      explines << "       7        8        1     14.3% src/ruby/charlie.rb"
      explines << "      10       15        5     50.0% total"
      
      assert_command RepositoryDiffer, %w{ -r19:22 }, explines
    end

    def test_revision_to_relative_revision
      explines = Array.new

      explines << "       3        7        4    133.3% SecondFile.txt"
      explines << "       7        8        1     14.3% src/ruby/charlie.rb"
      explines << "      10       15        5     50.0% total"
      
      assert_command RepositoryDiffer, %w{ -r19 -1 }, explines
    end
  end
end
