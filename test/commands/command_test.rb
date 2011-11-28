require File.dirname(__FILE__) + '/../test_helper.rb'

require 'rubygems'
require 'riel'
require 'pvn/commands/cachecmd'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module PVN
  class FakeCachableCommand < CachableCommand
    attr_reader :executed

    def initialize args
      @executed = false
      super
    end
    
    def run_command
      @executed = true
      super
    end
  end

  class CommandTest < Test::Unit::TestCase
    include Loggable

    WIQUERY_DIRNAME = "/home/jpace/Programs/wiquery/trunk"

    def initialize(*args)
      # save this because expand_path resolves to the current dir, which we
      # change during the tests.
      @original_dir = Pathname.new(__FILE__).expand_path
      super
    end

    def testfile basename
      @original_dir + '../../files' + basename
    end

    def read_testfile basename
      IO.readlines testfile basename
    end

    def remove_cache_dir
      cachetopdir = CachableCommand::CACHE_DIR      
      cachedir    = cachetopdir + WIQUERY_DIRNAME.to_s[1 .. -1]

      if cachedir.exist?
        cachedir.rmtree
      end
    end

    def setup
      @origdir = Pathname.pwd
      Dir.chdir WIQUERY_DIRNAME
      super
    end

    def teardown
      Dir.chdir @origdir
      super
    end

    def assert_command exp, cmdargs = nil
      fcc = FakeCachableCommand.new cmdargs
      info "fcc: #{fcc}"

      lines = fcc.lines
      # info "lines: #{lines}"

      origargs = cmdargs.dup
      assert_equal exp, fcc.executed, "arguments: #{origargs.inspect}"
    end

    def assert_executed cmdargs = nil
      assert_command true, cmdargs
    end

    def assert_not_executed cmdargs = nil
      assert_command false, cmdargs
    end

    def assert_svn_log expected_executed, use_cache, logargs = Array.new
      command = [ "svn", "log" ] + logargs
      assert_command expected_executed, :use_cache => use_cache, :command => command
    end

    # every testcase class must have a test method
    def test_nothing
    end
  end
end
