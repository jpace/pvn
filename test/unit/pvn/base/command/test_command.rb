require 'pvn/tc'
require 'system/cachecmd'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

puts "being loaded!: #{$0}".red

module PVN
  class FakeCachableCommand < CachableCommand
    attr_reader :executed

    def initialize args
      @executed = false
      super
    end    
  end

  class CommandTestCase < PVN::TestCase
    include Loggable

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
      # assert_command expected_executed, :use_cache => use_cache, :command_args => command
    end
  end
end
