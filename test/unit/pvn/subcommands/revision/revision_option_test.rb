#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'pvn/subcommands/revision/revision_option'

module PVN
  class MockRevisionOption < RevisionOption
    def run_log_command limit, path
      cmdargs = SVNx::LogCommandArgs.new :limit => limit, :path => path, :use_cache => false
      cmd = SVNx::LogCommand.new cmdargs
      cmd.execute
    end
    
  end

  class RevisionOptionTestCase < PVN::TestCase
    def assert_relative_to_absolute exp, val, path = '/Programs/wiquery/trunk'
      ropt = MockRevisionOption.new
      act = ropt.relative_to_absolute val, path
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
      assert_raises(RuntimeError) do 
        assert_relative_to_absolute '1944', '-164'
      end
    end

    def assert_post_process exp, val, path = '/Programs/wiquery/trunk'
      ropt = PVN::RevisionOption.new
      ropt.set_value val
      ropt.post_process nil, [ path ]
      act = ropt.value
      assert_equal exp, act, "val: #{val}; path: #{path}"
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
