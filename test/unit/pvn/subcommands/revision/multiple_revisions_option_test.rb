#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'pvn/subcommands/revision/multiple_revisions_option'
require 'pvn/subcommands/revision/tc'

module PVN
  class MultipleRevisionsRegexpOptionTestCase < BaseRevisionOptionTestCase
    def create_option
      PVN::MultipleRevisionsRegexpOption.new
    end

    def set_value opt, vals
      vals.each do |val|
        opt.set_value val
      end
    end

    def test_out_of_range
      assert_raises(RuntimeError) do 
        ropt = PVN::MultipleRevisionsRegexpOption.new
        ropt.process [ '-164' ]
        ropt.post_process nil, [ '/Programs/wiquery/trunk' ]
      end
    end

    def test_post_process_single_middling
      assert_post_process [ '1887' ], [ '-7' ]
    end

    def test_post_process_single_latest
      assert_post_process [ '1950' ], '-1'
    end

    def test_post_process_single_oldest
      assert_post_process [ '412' ], '-163'
    end

    def test_post_process_single_tagval_unconverted
      assert_post_process [ '7' ], '-r7'
    end

    def test_post_process_single_tagrange_unconverted
      assert_post_process [ '7:177' ], '-r7:177'
    end

    def test_post_process_multiple_middling
      assert_post_process [ '1887', '1950' ], [ '-7', '-1' ]
    end

    def test_post_process_multiple_relative_tagval_unconverted
      assert_post_process [ '1944', '7' ], [ '-5', '-r7' ]
    end

    def test_process_tag_value
      assert_process %w{ 317 }, %w{ -r 317 }
    end
  end
end
