require 'tc'
require 'system/command/caching'
require 'zlib'

module System
  class CacheFileTestCase < PVN::TestCase
    include Loggable

    CACHE_DIR = Pathname.new '/tmp/pvn/testing'

    def setup
      super
      CACHE_DIR.rmtree if CACHE_DIR.exist?
    end

    def teardown
      super
      CACHE_DIR.rmtree if CACHE_DIR.exist?
    end

    def test_creates_gzfile
      cf = CacheFile.new CACHE_DIR, [ "ls", "/var/tmp" ]
      info "cf: #{cf}".yellow
      cfpn = cf.instance_eval '@pn'
      cfpn.unlink if cfpn.exist?
      
      lines = cf.readlines
      info "lines: #{lines}".yellow

      cfpn = cf.instance_eval '@pn'
      info "cfpn: #{cfpn}".yellow
      assert cfpn.exist?

      Zlib::GzipReader.open(cfpn.to_s) do |gz|
        fromgz = gz.readlines
        assert_equal lines, fromgz
      end
    end

    def test_reads_gzfile
      cf = CacheFile.new CACHE_DIR, [ "ls", "-l", "/var/tmp" ]
      info "cf: #{cf}".yellow
      cfpn = cf.instance_eval '@pn'
      cfpn.unlink if cfpn.exist?
      
      lines = cf.readlines
      info "lines: #{lines}".yellow

      cfpn = cf.instance_eval '@pn'
      info "cfpn: #{cfpn}".yellow
      assert cfpn.exist?

      # same as above
      cf2 = CacheFile.new CACHE_DIR, [ "ls", "-l", "/var/tmp" ]
      info "cf2: #{cf2}".magenta
      
      def cf2.save_file
        fail "should not have called save file for read"
      end

      lines2 = cf2.readlines
      info "lines2: #{lines2}".magenta

      assert_equal lines2, lines

      Zlib::GzipReader.open(cfpn.to_s) do |gz|
        fromgz = gz.readlines
        assert_equal lines, fromgz
      end
    end
  end
end
