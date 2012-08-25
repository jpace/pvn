#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'pvn/subcommands/revision/multiple_revisions_option'

Log.level = Log::DEBUG

module PVN
  class MultipleRevisionsRegexpOptionTestCase < PVN::TestCase
    def test_out_of_range
      assert_raises(RuntimeError) do 
        ropt = PVN::MultipleRevisionsRegexpOption.new
        ropt.process [ '-164' ]
        ropt.post_process nil, [ '/Programs/wiquery/trunk' ]
      end
    end

    def assert_post_process exp, vals, path
      ropt = PVN::MultipleRevisionsRegexpOption.new
      vals.each do |val|
        info "val: #{val.inspect}; val.class: #{val.class}".red
        ropt.set_value val
      end
      ropt.post_process nil, [ path ]
      act = ropt.value
      assert_equal exp, act, "vals: #{vals}; path: #{path}"
    end

    def test_post_process_single_middling
      assert_post_process [ '1887' ], [ '-7' ], '/Programs/wiquery/trunk'
    end

    def test_post_process_single_latest
      assert_post_process [ '1950' ], '-1', '/Programs/wiquery/trunk'
    end

    def test_post_process_single_oldest
      assert_post_process [ '412' ], '-163', '/Programs/wiquery/trunk'
    end

    def test_post_process_single_tagval_unconverted
      assert_post_process [ '7' ], '-r7', '/Programs/wiquery/trunk'
    end

    def test_post_process_single_tagrange_unconverted
      assert_post_process [ '7:177' ], '-r7:177', '/Programs/wiquery/trunk'
    end

    def test_post_process_multiple_middling
      assert_post_process [ '1887', '1950' ], [ '-7', '-1' ], '/Programs/wiquery/trunk'
    end

    def test_post_process_multiple_relative_tagval_unconverted
      assert_post_process [ '1944', '7' ], [ '-5', '-r7' ], '/Programs/wiquery/trunk'
    end

    def assert_process exp, args, path
      ropt = PVN::MultipleRevisionsRegexpOption.new
      ropt.process args
      ropt.post_process nil, [ path ]
      act = ropt.value
      assert_equal exp, act, "args: #{args}; path: #{path}"
    end

    def test_process_tag_value
      assert_process %w{ 317 }, %w{ -r 317 }, '/Programs/wiquery/trunk'
    end
  end
end
