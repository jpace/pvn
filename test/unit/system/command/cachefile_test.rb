#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'system/command/tc'
require 'system/command/caching'
require 'zlib'

module System
  class CacheFileTestCase < CommandTestCase
    CACHE_DIR = Pathname.new '/tmp/pvn/testing'

    def test_creates_gzfile
      cf = CacheFile.new CACHE_DIR, [ "ls", "/var/tmp" ]
      cfpn = cf.instance_eval '@pn'
      cfpn.unlink if cfpn.exist?
      
      lines = cf.readlines

      cfpn = cf.instance_eval '@pn'
      assert cfpn.exist?

      Zlib::GzipReader.open(cfpn.to_s) do |gz|
        fromgz = gz.readlines
        assert_equal lines, fromgz
      end
    end

    def test_reads_gzfile
      cf = CacheFile.new CACHE_DIR, [ "ls", "-l", "/var/tmp" ]
      cfpn = cf.instance_eval '@pn'
      cfpn.unlink if cfpn.exist?
      
      lines = cf.readlines

      cfpn = cf.instance_eval '@pn'
      assert cfpn.exist?

      # same as above
      cf2 = CacheFile.new CACHE_DIR, [ "ls", "-l", "/var/tmp" ]
      
      def cf2.save_file
        fail "should not have called save file for read"
      end

      lines2 = cf2.readlines

      assert_equal lines2, lines

      fromgz = read_gzfile cfpn
      assert_equal lines, fromgz
    end
  end
end
