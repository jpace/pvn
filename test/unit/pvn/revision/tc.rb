#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'svnx/revision/error'
require 'svnx/revision/argument'

module PVN
  module MockBaseRevisionOption
    def run_log_command limit, path
      xmllines = if path == Resources::PT_PATH
                   case limit
                   when 1
                     Resources::PT_LOG_R19.readlines
                   when 5
                     Resources::PT_LOG_R19_15.readlines
                   when 7
                     Resources::PT_LOG_R19_13.readlines
                   when 19
                     Resources::PT_LOG_R19_1.readlines
                   when 20
                     Resources::PT_LOG_R19_1.readlines
                   else
                     fail "limit not handled: #{limit}; #{path}"
                   end
                 else
                   fail "path not handled: #{path}"
                 end
      SVNx::Log::Entries.new(:xmllines => xmllines).entries
    end
  end
  
  class BaseRevisionOptionTestCase < PVN::TestCase
    def create_option
    end

    def assert_post_process exp, val, path = Resources::PT_PATH
      opt = create_option
      set_value opt, val
      opt.post_process nil, [ path ]
      act = opt.value
      assert_equal exp, act, "val: #{val}; path: #{path}"
    end

    def assert_process exp, args, path = Resources::PT_PATH
      opt = create_option
      opt.process args
      opt.post_process nil, [ path ]
      act = opt.value
      assert_equal exp, act, "args: #{args}; path: #{path}"
    end

    def assert_revision_option_raises val, path = Resources::PT_PATH
      assert_raises(SVNx::Revision::RevisionError) do 
        opt = create_option
        # opt.process [ val ]
        opt.set_value val
        opt.post_process nil, [ path ]
      end
    end
  end
end
