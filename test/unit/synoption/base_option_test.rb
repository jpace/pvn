#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'synoption/base_option'
require 'stringio'

module PVN
  class BaseOptionTestCase < Test::Unit::TestCase
    include Loggable
    
    def test_init_minimal
      opt = BaseOption.new :limit, '-l', "the number of log entries", nil
      assert_equal :limit, opt.name
      assert_equal '-l', opt.tag
      assert_equal "the number of log entries", opt.description
    end

    def test_init_default_value
      opt = BaseOption.new :nombre, '-x', " one two three", 133
      assert_equal 133, opt.value
    end

    def test_init_negate
      opt = BaseOption.new :limit, '-l', "the number of log entries", nil, :negate => [ %r{^--no-?limit} ]
      assert_equal [ %r{^--no-?limit} ], opt.negate
    end

    def test_to_doc
      opt = BaseOption.new :limit, '-l', "the number of log entries", 777, :negate => [ %r{^--no-?limit} ]
      sio = StringIO.new
      opt.to_doc sio
      exp = String.new
      exp << "  -l [--limit] ARG         : the number of log entries\n"
      exp << "                               default: 777\n"
      exp << "  --no-limit                 \n"
      assert_equal exp, sio.string
    end

    def assert_exact_match exp, opt, val
      assert_equal exp, opt.exact_match?(val), "value: '" + val + "'"
    end

    def test_exact_match
      opt = BaseOption.new :limit, '-l', "the number of log entries", 3
      [ '-l', '--limit' ].each do |val|
        assert_exact_match true, opt, val
      end

      [ '-L', '-x', '--lim', '--liMit' ].each do |val|
        assert_exact_match false, opt, val
      end
    end

    def assert_negative_match exp, opt, val
      info "val: #{val}"
      md = opt.negative_match? val
      assert_equal exp, !!md, "value: '" + val + "'"
    end

    def test_negative_match
      opt = BaseOption.new :limit, '-l', "the number of log entries", 777, :negate => [ '-L', %r{^--no-?limit} ]
      [ '-L', '--no-limit', '--nolimit' ].each do |val|
        assert_negative_match true, opt, val
      end

      [ '-l', '-x', '-nolimit', '  --nolimit' ].each do |val|
        assert_negative_match false, opt, val
      end
    end

    def assert_regexp_match exp, opt, val
      md = opt.regexp_match? val
      assert_equal exp, !!md, "value: '" + val + "'"
    end

    def test_regexp_match
      opt = BaseOption.new :revision, '-r', "the revision", nil, :regexp => Regexp.new('^[\-\+]\d+$')
      [ '-1', '-123', '+99', '+443' ].each do |val|
        assert_regexp_match true, opt, val
      end

      [ '-x', '123', '+-x', 'word' ].each do |val|
        assert_regexp_match false, opt, val
      end
    end

    def assert_to_command_line exp, opt
      assert_equal exp, opt.to_command_line
    end

    def test_to_command_line_no_cmdline_option
      opt = BaseOption.new :xyz, '-x', "the blah blah blah", nil
      assert_to_command_line nil, opt
      opt.set_value 1
      assert_to_command_line [ '-x', 1 ], opt
    end

    def test_to_command_line_cmdline_option_string
      opt = BaseOption.new :xyz, '-x', "the blah blah blah", nil, :as_cmdline_option => '--xray'
      assert_to_command_line nil, opt
      opt.set_value 1
      assert_to_command_line '--xray', opt
    end

    def test_to_command_line_cmdline_option_nil
      opt = BaseOption.new :xyz, '-x', "the blah blah blah", nil, :as_cmdline_option => nil
      assert_to_command_line nil, opt
      opt.set_value 1
      assert_to_command_line nil, opt
    end

    def test_takes_value
      opt = BaseOption.new :xyz, '-x', "the blah blah blah", nil
      assert opt.takes_value?
    end
  end
end
