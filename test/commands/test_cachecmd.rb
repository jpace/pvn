require File.dirname(__FILE__) + '/../test_helper.rb'

require 'rubygems'
require 'riel'
require 'pvn/commands/cachecmd'

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
      
      def run_command
        @executed = true
        super
      end
    end

    WIQUERY_DIRNAME = "/home/jpace/Programs/wiquery"

    def remove_cache_dir
      cachetopdir = CachableCommand::CACHE_DIR
      info "cachetopdir: #{cachetopdir}".red

      cachedir = cachetopdir + WIQUERY_DIRNAME.to_s[1 .. -1]
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

    def test_cached_no_changes
      remove_cache_dir
      info "running first one ..."
      assert_svn_log true, true

      info "running second one ..."
      assert_svn_log false, true
    end

    def test_cached_different_arguments
      remove_cache_dir
      info "running first one ..."
      assert_svn_log true, true, [ '-l', 5 ]
      
      info "running second one ..."
      assert_svn_log true, true, [ '-l', 6 ]
    end

    def test_uncached_command
      remove_cache_dir
      info "running first one ..."
      assert_svn_log true, false
      
      info "running second one ..."
      assert_svn_log true, false
    end
  end
end
