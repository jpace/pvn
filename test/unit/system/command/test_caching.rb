require 'tc'
require 'system/command/caching'

module PVN
  module System
    class CachingCommandLineTestCase < PVN::TestCase
      include Loggable

      CACHE_DIR = Pathname.new '/tmp/pvn/testing'

      def setup
        super
        info "self: #{self}"
        CACHE_DIR.rmtree if CACHE_DIR.exist?
      end

      def teardown
        CACHE_DIR.rmtree if CACHE_DIR.exist?
        super
        info "self: #{self}"
      end

      def test_ctor_no_args
        cl = CachingCommandLine.new [ "ls" ]
        assert_equal "ls", cl.to_command
      end

      def test_ctor_with_args
        cl = CachingCommandLine.new [ "ls", "/tmp" ]
        assert_equal "ls /tmp", cl.to_command
      end

      def test_lshift
        cl = CachingCommandLine.new [ "ls" ]
        cl << "/tmp"
        assert_equal "ls /tmp", cl.to_command
      end

      def test_cache_dir_defaults_to_executable
        cl = CachingCommandLine.new [ "ls" ]
        cl << "/tmp"
        info "$0: #{$0}".on_blue
        info "cl.cache_dir: #{cl.cache_dir}".on_blue
        assert_equal '/tmp' + (Pathname.new($0).expand_path).to_s, cl.cache_dir
      end

      def test_cache_file_defaults_to_executable
        cl = CachingCommandLine.new [ "ls" ]
        cl << "/tmp"
        assert_equal '/tmp' + (Pathname.new($0).expand_path).to_s + '/ls-\/tmp', cl.cache_file.to_s
      end

      def test_cache_dir_set_cachefile
        cl = CachingCommandLine.new [ "ls" ]
        cl << "/tmp"
        def cl.cache_dir; CACHE_DIR.to_s; end
        assert_not_nil cl.cache_dir
        assert !CACHE_DIR.exist?

        cachefile = cl.cache_file
        assert_equal CACHE_DIR.to_s + '/ls-\/tmp', cachefile.to_s
      end

      def test_cache_dir_created_on_execute
        cl = CachingCommandLine.new [ "ls" ]
        cl << "/tmp"
        def cl.cache_dir; CACHE_DIR.to_s; end

        cachefile = cl.cache_file

        cl.execute
        assert CACHE_DIR.exist?
        cachelines = IO.readlines cachefile.to_s

        syslines = nil
        IO.popen("ls /tmp") do |io|
          syslines = io.readlines
        end

        assert_equal syslines, cachelines
      end

      def test_cache_file_matches_results
        dir = "/usr/local/bin"
        cl = CachingCommandLine.new [ "ls", dir ]
        def cl.cache_dir; CACHE_DIR.to_s; end

        cachefile = cl.cache_file

        cl.execute
        assert CACHE_DIR.exist?
        cachelines = IO.readlines cachefile.to_s

        syslines = nil
        IO.popen("ls #{dir}") do |io|
          syslines = io.readlines
        end

        assert_equal syslines, cachelines
      end
    end
  end
end
