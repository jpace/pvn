require File.dirname(__FILE__) + '/../test_helper.rb'

require 'rubygems'
require 'riel'
require 'pvn/commands/cachecmd'
require 'mocklog'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module PVN
  class TestCommand < Test::Unit::TestCase
    include Loggable

    class FakeCachableCommand < CachableCommand
      attr_reader :executed

      def initialize args
        @executed = false
        super
      end
      
      def run_command cmd
        @executed = true
        super
      end
    end

    WIQUERY_DIRNAME = "/home/jpace/Programs/wiquery"

    def remove_cache_dir
      wiquery_dirname = "/home/jpace/Programs/wiquery"

      # remove the cache directory ...
      cachetopdir = CachableCommand::CACHE_DIR
      info "cachetopdir: #{cachetopdir}".red

      cachedir = cachetopdir + wiquery_dirname.to_s[1 .. -1]
      info "cachedir: #{cachedir}"

      if cachedir.exist?
        cachedir.rmtree
      end
    end

    def setup
      puts "setting up!"
      @origdir = Pathname.pwd
      Dir.chdir WIQUERY_DIRNAME
    end

    def teardown
      puts "tearing down!"
      Dir.chdir @origdir
    end

    def assert_command exp, cmdargs = nil
      fcc = FakeCachableCommand.new cmdargs
      info "fcc: #{fcc}"

      lines = fcc.lines
      # info "lines: #{lines}"

      origargs = cmdargs.dup
      assert_equal exp, fcc.executed, "arguments: #{origargs.inspect}"

      # origargs = cmdargs && cmdargs.dup
      # assert_equal exp, LogCommand.new(:execute => false, :command_args => cmdargs, :executor => @mle).command, "arguments: " + origargs.to_s
    end

    def test_uncached
      remove_cache_dir
      info "running first one ..."
      assert_command true, [ "svn", "log" ]
      
      info "running second one ..."
      assert_command false, [ "svn", "log" ]
    end

    def xtest_cached_no_change
    end

    def xtest_cached_changed
    end
  end
end

