#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'

module PVN
  class BaseRevisionOptionTestCase < PVN::TestCase
    def create_option
    end

    def assert_post_process exp, val, path = '/Programs/wiquery/trunk'
      opt = create_option
      set_value opt, val
      opt.post_process nil, [ path ]
      act = opt.value
      assert_equal exp, act, "val: #{val}; path: #{path}"
    end

    def assert_process exp, args, path = '/Programs/wiquery/trunk'
      ropt = create_option
      ropt.process args
      ropt.post_process nil, [ path ]
      act = ropt.value
      assert_equal exp, act, "args: #{args}; path: #{path}"
    end
  end
end
