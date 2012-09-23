require 'tc'
require 'system/command/caching'

module System
  class CachingCommandLineTestCase < PVN::TestCase
    include Loggable

    CACHE_DIR = Pathname.new '/tmp/pvn/testing'

    def setup
      super
      CACHE_DIR.rmtree if CACHE_DIR.exist?
    end

    def teardown
      CACHE_DIR.rmtree if CACHE_DIR.exist?
      super
    end

    def create_ls_tmp
      CachingCommandLine.new [ "ls", "/bin" ]
    end

    def test_ctor_no_args
      cl = CachingCommandLine.new [ "ls" ]
      assert_equal "ls", cl.to_command
    end

    def test_ctor_with_args
      cl = CachingCommandLine.new [ "ls", "/bin" ]
      assert_equal "ls /bin", cl.to_command
    end

    def test_lshift
      cl = CachingCommandLine.new [ "ls" ]
      cl << "/bin"
      assert_equal "ls /bin", cl.to_command
    end

    def test_cache_dir_defaults_to_executable
      cl = create_ls_tmp
      assert_equal '/tmp' + (Pathname.new($0).expand_path).to_s, cl.cache_dir
    end

    def test_cache_file_defaults_to_executable
      cl = create_ls_tmp
      info "cl.cache_file.to_s: #{cl.cache_file.to_s}"
      assert_equal '/tmp' + (Pathname.new($0).expand_path).to_s + '/ls-\/bin', cl.cache_file.to_s
    end

    def test_cache_dir_set_cachefile
      cl = create_ls_tmp
      def cl.cache_dir; CACHE_DIR.to_s; end
      assert_not_nil cl.cache_dir
      assert !CACHE_DIR.exist?

      cachefile = cl.cache_file
      assert_equal CACHE_DIR.to_s + '/ls-\/bin', cachefile.to_s
    end

    def test_cache_dir_created_on_execute
      cl = create_ls_tmp
      def cl.cache_dir; CACHE_DIR.to_s; end

      cachefile = cl.cache_file

      cl.execute
      assert CACHE_DIR.exist?
      cachelines = IO.readlines cachefile.to_s

      syslines = nil
      # we can't use /tmp, since this test will add to it:
      IO.popen("ls /bin") do |io|
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
