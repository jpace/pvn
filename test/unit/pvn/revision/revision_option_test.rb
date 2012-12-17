#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/revision/tc'
require 'pvn/revision/revision_option'

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

    def assert_relative_to_absolute exp, val, path = Resources::PT_PATH
      ropt = MockRevisionOption.new
      act = ropt.relative_to_absolute val, path
      assert_equal exp, act, "val: #{val}; path: #{path}"
    end

    def test_relative_to_absolute_middling
      assert_relative_to_absolute '13', '-7'
    end

    def test_relative_to_absolute_latest
      assert_relative_to_absolute '19', '-1'
    end

    def test_relative_to_absolute_oldest
      assert_relative_to_absolute '1', '-19'
    end

    def test_out_of_range
      assert_revision_option_raises '-20'
    end

    def test_post_process_absolute_middling
      assert_post_process '13', '13'
    end

    def test_post_process_middling
      assert_post_process '13', '-7'
    end

    def test_post_process_latest
      assert_post_process '19', '-1'
    end

    def test_post_process_oldest
      assert_post_process '1', '-19'
    end
  end
end
