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

      def test_ctor
        cl = CachingCommandLine.new [ "ls" ]
        assert_equal "ls", cl.to_command
        assert cl.use_cache?
      end

      def test_lshift
        cl = CachingCommandLine.new [ "ls" ]
        cl << "/tmp"
        assert cl.use_cache?
        assert_equal "ls /tmp", cl.to_command
      end

      def test_cache_dir_defaults_to_nil
        cl = CachingCommandLine.new [ "ls" ]
        cl << "/tmp"
        assert_equal "ls /tmp", cl.to_command
        assert cl.use_cache?
        assert_nil cl.cache_dir
      end

      def test_cache_dir_set_cachefile
        cl = CachingCommandLine.new [ "ls" ]
        cl << "/tmp"
        assert_equal "ls /tmp", cl.to_command
        assert cl.use_cache?
        assert_nil cl.cache_dir
        def cl.cache_dir; CACHE_DIR.to_s; end
        assert_not_nil cl.cache_dir
        assert !CACHE_DIR.exist?

        cachefile = cl.cache_file
        assert_equal '/tmp/pvn/testing/projorgincavapvn/ls-/tmp', cachefile.to_s
      end

      def test_cache_dir_set
        cl = CachingCommandLine.new [ "ls" ]
        cl << "/tmp"
        assert_equal "ls /tmp", cl.to_command
        assert cl.use_cache?
        assert_nil cl.cache_dir
        def cl.cache_dir; CACHE_DIR.to_s; end
        assert_not_nil cl.cache_dir
        assert !CACHE_DIR.exist?

        cachefile = cl.cache_file
        assert_equal '/tmp/pvn/testing/projorgincavapvn/ls-/tmp', cachefile.to_s

        cl.execute
        assert CACHE_DIR.exist?
        cachelines = IO.readlines cachefile.to_s

        syslines = nil
        IO.popen("ls /tmp") do |io|
          syslines = io.readlines
        end

        assert_equal syslines, cachelines
      end
    end
  end
end
