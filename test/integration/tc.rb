#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'svnx/log/command'
require 'rexml/document'

module PVN
  class IntegrationTestCase < PVN::TestCase
    include Loggable

    PT_DIRNAME = '/Programs/pvn/pvntestbed.from'

    def setup
      @cache_dir = ENV['PVN_CACHE_DIR'] || '/tmp/pvncache'
      info "@cache_dir: #{@cache_dir}"
      remove_cache_dir
      
      super

      @origdir = Dir.pwd
      Dir.chdir PT_DIRNAME
    end

    def teardown
      remove_cache_dir        
      super
    end

    def remove_cache_dir
      pn = Pathname.new @cache_dir
      info "pn: #{pn}".red
      pn.rmtree if pn.exist?
    end

    def assert_cache_dir_exists expected
      pn = Pathname.new @cache_dir
      assert_equal expected, pn.exist?
    end

    def find_subelement_by_name elmt, name
      subelmt = elmt.elements.detect { |el| el.name == name }
      subelmt ? subelmt.get_text.to_s : nil
    end
  end
end
