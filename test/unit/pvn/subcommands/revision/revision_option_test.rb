#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'pvn/subcommands/revision/revision_option'
require 'pvn/subcommands/revision/tc'

module PVN
  class MockRevisionOption < RevisionOption
    include MockBaseRevisionOption
  end

  class RevisionOptionTestCase < BaseRevisionOptionTestCase
    def create_option
      PVN::MockRevisionOption.new
    end

    def set_value opt, val
      opt.set_value val
    end

    def assert_relative_to_absolute exp, val, path = '/Programs/wiquery/trunk'
      ropt = MockRevisionOption.new
      act = ropt.relative_to_absolute val, path
      info "act: #{act}".cyan
      assert_equal exp, act, "val: #{val}; path: #{val}"
    end

    def test_relative_to_absolute_middling
      assert_relative_to_absolute '1887', '-7'
    end

    def test_relative_to_absolute_latest
      assert_relative_to_absolute '1950', '-1'
    end

    def test_relative_to_absolute_oldest
      assert_relative_to_absolute '412', '-163'
    end

    def test_out_of_range
      assert_raises(PVN::Revision::RevisionError) do 
        assert_relative_to_absolute '1944', '-164'
      end
    end

    def test_post_process_absolute_middling
      assert_post_process '1887', '1887'
    end

    def test_post_process_middling
      assert_post_process '1887', '-7'
    end

    def test_post_process_latest
      assert_post_process '1950', '-1'
    end

    def test_post_process_oldest
      assert_post_process '412', '-163'
    end
  end
end
