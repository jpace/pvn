#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'pvn/subcommands/revision/multiple_revisions_option'
require 'pvn/subcommands/revision/tc'

module PVN
  class MockMultipleRevisionsRegexpOption < MultipleRevisionsRegexpOption
    include MockBaseRevisionOption
  end

  class MultipleRevisionsRegexpOptionTestCase < BaseRevisionOptionTestCase
    def create_option
      PVN::MockMultipleRevisionsRegexpOption.new
    end

    def set_value opt, vals
      vals.each do |val|
        opt.set_value val
      end
    end

    def test_out_of_range
      assert_revision_option_raises '-20'
    end

    def test_post_process_single_middling
      assert_post_process [ '13' ], [ '-7' ]
    end

    def test_post_process_single_latest
      assert_post_process [ '19' ], '-1'
    end

    def test_post_process_single_oldest
      assert_post_process [ '1' ], '-19'
    end

    def test_post_process_single_tagval_unconverted
      assert_post_process [ '7' ], '-r7'
    end

    def test_post_process_single_tagrange_unconverted
      assert_post_process [ '7:17' ], '-r7:17'
    end

    def test_post_process_multiple_middling
      assert_post_process [ '13', '19' ], [ '-7', '-1' ]
    end

    def test_post_process_multiple_relative_tagval_unconverted
      assert_post_process [ '15', '7' ], [ '-5', '-r7' ]
    end

    def test_process_tag_value
      assert_process %w{ 17 }, %w{ -r 17 }
    end
  end
end
