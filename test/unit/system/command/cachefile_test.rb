require 'tc'
require 'system/command/caching'

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

    def test_default
      cf = CacheFile.new CACHE_DIR, [ "ls", "/var/tmp" ]
      info "cf: #{cf}".yellow
      
      lines = cf.readlines
      info "lines: #{lines}".yellow

      cfpn = cf.instance_eval '@pn'
      assert cfpn.exist?

      lines = cf.readlines
      info "lines: #{lines}".yellow
    end
  end
end
