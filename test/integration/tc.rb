#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'svnx/log/command'
require 'rexml/document'
require 'svnx/log/logdata'

module PVN
  class IntegrationTestCase < PVN::TestCase
    include Loggable

    def setup
      @cache_dir = PVN::Environment.instance.cache_dir
      info "@cache_dir: #{@cache_dir}"
      remove_cache_dir
      
      super

      @origdir = Dir.pwd
      Dir.chdir '/Programs/wiquery/trunk'
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

    def assert_log_entry elmt, expdata = Hash.new
      assert_equal 'logentry', elmt.name

      info "elmt: #{elmt}"
      assert_equal expdata[:author], find_subelement_by_name(elmt, 'author')
      assert_equal expdata[:date], find_subelement_by_name(elmt, 'date')
      assert_equal expdata[:msg], find_subelement_by_name(elmt, 'msg')
    end

    def assert_entry_equals entry, expdata
      assert_equal expdata[0], entry.revision
      assert_equal expdata[1], entry.author
      assert_equal expdata[2], entry.date
      assert_equal expdata[3], entry.message
      entry.paths.each_with_index do |path, idx|
        info path.inspect.yellow
        assert_equal expdata[4 + idx][:kind], path.kind
        assert_equal expdata[4 + idx][:action], path.action
        assert_equal expdata[4 + idx][:name], path.name
      end
    end
  end
end
