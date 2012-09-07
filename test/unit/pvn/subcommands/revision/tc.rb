#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'resources'

module PVN
  module MockBaseRevisionOption
    def run_log_command limit, path
      info "limit: #{limit}; #{limit.class}".red
      info "path : #{path}".red
      if path == Resources::WIQTR_PATH
        case limit
        when 1
          Resources::WIQTR_LOG_LIMIT_1.readlines
        when 5
          Resources::WIQTR_LOG_LIMIT_5.readlines
        when 7
          Resources::WIQTR_LOG_LIMIT_7.readlines
        when 163
          Resources::WIQTR_LOG_LIMIT_163.readlines
        when 164
          Resources::WIQTR_LOG_LIMIT_164.readlines
        else
          fail "limit not handled: #{limit}; #{path}"
        end
      else
        fail "path not handled: #{path}"
      end
    end
  end
  
  class BaseRevisionOptionTestCase < PVN::TestCase
    def create_option
    end

    def assert_post_process exp, val
      opt = create_option
      set_value opt, val
      opt.post_process nil, [ Resources::WIQTR_PATH ]
      act = opt.value
      assert_equal exp, act, "val: #{val}; path: #{Resources::WIQTR_PATH}"
    end

    def assert_process exp, args
      opt = create_option
      opt.process args
      opt.post_process nil, [ Resources::WIQTR_PATH ]
      act = opt.value
      assert_equal exp, act, "args: #{args}; path: #{Resources::WIQTR_PATH}"
    end

    def assert_revision_option_raises val
      assert_raises(PVN::Revision::RevisionError) do 
        opt = create_option
        opt.process [ val ]
        opt.post_process nil, [ Resources::WIQTR_PATH ]
      end
    end
  end
end
