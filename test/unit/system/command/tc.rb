#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'zlib'
require 'pathname'

module System
  class CommandTestCase < PVN::TestCase
    CACHE_DIR = Pathname.new '/tmp/pvn/testing'

    def setup
      super
      CACHE_DIR.rmtree if CACHE_DIR.exist?
    end

    def teardown
      super
      CACHE_DIR.rmtree if CACHE_DIR.exist?
    end

    def read_gzfile gzfile
      lines = nil
      Zlib::GzipReader.open(gzfile.to_s) do |gz|
        lines = gz.readlines
      end
      lines
    end
  end
end
