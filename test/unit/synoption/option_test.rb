#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'synoption/option'
require 'stringio'

module PVN
  class OptionTestCase < Test::Unit::TestCase
    include Loggable
    
    def test_init_minimal
      opt = Option.new :limit, '-l', "the number of log entries"
      assert_equal :limit, opt.name
      assert_equal '-l', opt.tag
      assert_equal "the number of log entries", opt.description
      opts = opt.options
      assert_not_nil opts
    end

    def test_init_default_value
      opt = Option.new :nombre, '-x', " one two three", :default => 133
      assert_equal 133, opt.value
    end

    def test_init_negate
      opt = Option.new :limit, '-l', "the number of log entries", :negate => [ %r{^--no-?limit} ]
      opts = opt.options
      assert_not_nil opts
      assert_equal [ %r{^--no-?limit} ], opts[:negate]
    end

    def test_to_doc
      opt = Option.new :limit, '-l', "the number of log entries", :default => 777, :negate => [ %r{^--no-?limit} ]
      sio = StringIO.new
      opt.to_doc sio
      puts sio.string
      exp = String.new
      exp << "  -l [--limit] ARG         : the number of log entries\n"
      exp << "                               default: 777\n"
      exp << "  --no-limit                 \n"
      assert_equal exp, sio.string
    end

  end
end
