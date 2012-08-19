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

    def make_xyz_option options = Hash.new
      BaseOption.new :xyz, '-x', "the blah blah blah", nil, options
    end

    def test_to_command_line_no_cmdline_option
      opt = make_xyz_option
      assert_to_command_line nil, opt
      opt.set_value 1
      assert_to_command_line [ '-x', 1 ], opt
    end

    def test_to_command_line_cmdline_option_string
      opt = make_xyz_option :as_cmdline_option => '--xray'
      assert_to_command_line nil, opt
      opt.set_value 1
      assert_to_command_line '--xray', opt
    end

    def test_to_command_line_cmdline_option_nil
      opt = make_xyz_option :as_cmdline_option => nil
      assert_to_command_line nil, opt
      opt.set_value 1
      assert_to_command_line nil, opt
    end

    def test_takes_value
      opt = make_xyz_option
      assert opt.takes_value?
    end

    def assert_process exp_process, exp_value, exp_remaining_args, opt, args
      pr = opt.process args
      assert_equal exp_process, pr
      assert_equal exp_value, opt.value
      assert_equal exp_remaining_args, args
    end

    def test_process_exact_no_match
      opt = make_xyz_option
      args = %w{ --baz foo }
      assert_process false, nil, %w{ --baz foo }, opt, args
    end

    def test_process_exact_takes_argument
      opt = make_xyz_option
      args = %w{ --xyz foo }
      assert_process true, 'foo', %w{ }, opt, args

      opt = make_xyz_option
      args = %w{ --xyz foo bar }
      assert_process true, 'foo', %w{ bar }, opt, args
    end

    def test_process_exact_takes_missing_argument
      opt = make_xyz_option
      args = %w{ --xyz }
      assert_raises(RuntimeError) do 
        assert_process true, 'foo', %w{ }, opt, args
      end
    end

    def test_process_negative
      options = { :negate => [ '-X', %r{^--no-?xyz} ] }
      %w{ -X --no-xyz --noxyz }.each do |arg|
        opt = make_xyz_option options
        args = [ arg ]
        assert_process true, false, %w{ }, opt, args
      end

      %w{ -X --no-xyz --noxyz }.each do |arg|
        opt = make_xyz_option options
        args = [ arg, '--abc' ]
        assert_process true, false, %w{ --abc }, opt, args
      end
    end

    def test_process_regexp
      options = { :regexp => Regexp.new('^[\-\+]\d+$') }
      %w{ -1 +123 }.each do |arg|
        opt = make_xyz_option options
        args = [ arg ]
        assert_process true, arg, %w{ }, opt, args
      end

      %w{ -1 +123 }.each do |arg|
        opt = make_xyz_option options
        args = [ arg, '--foo' ]
        assert_process true, arg, %w{ --foo }, opt, args
      end
    end
  end
end
