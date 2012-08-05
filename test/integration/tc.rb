#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'svnx/log/command'
require 'rexml/document'

module PVN
  class IntegrationTestCase < PVN::TestCase
    include Loggable

    WIQUERY_DIRNAME = '/Programs/wiquery/trunk'

    def setup
      @cache_dir = PVN::Environment.instance.cache_dir
      info "@cache_dir: #{@cache_dir}"
      remove_cache_dir
      
      super

      @origdir = Dir.pwd
      Dir.chdir WIQUERY_DIRNAME
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
