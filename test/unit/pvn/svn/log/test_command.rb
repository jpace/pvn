#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/tc'
require 'pvn/svn/log/command'
require 'rexml/document'

module PVN
  module SVN
    class TestLogCommand < PVN::TestCase
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
        info "pn: #{pn}".on_blue
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

      def assert_log_entries cmd
        info "cmd: #{cmd}"
        doc = REXML::Document.new cmd.output.join ''

        elements = doc.elements
        assert_equal 1, elements.size

        logelmt = elements[1]

        assert_equal 'log', logelmt.name
        
        logentryelmts = logelmt.elements

        assert_equal 163, logentryelmts.size

        expdata = Hash.new
        expdata[:author] = 'jpace'
        expdata[:date] = '2011-12-05T12:41:52.385786Z'
        expdata[:msg] = 'Testing.'

        assert_log_entry logentryelmts[1], expdata

        expdata = Hash.new
        expdata[:author] = 'hielke.hoeve@gmail.com'
        expdata[:date] = '2011-09-28T14:32:43.601185Z'
        expdata[:msg] = 'rework of the js/css/string tokens for post rendering.'
        assert_log_entry logentryelmts[17], expdata
      end

      def test_xml_output
        cmd = LogCommand.new :use_cache => false
        assert_log_entries cmd
      end

      def test_cache_not_created
        assert_cache_dir_exists false
        cmd = LogCommand.new :use_cache => false
        assert_cache_dir_exists false
      end        

      def test_cache_created
        assert_cache_dir_exists false
        cmd = LogCommand.new :use_cache => true
        assert_cache_dir_exists true
      end
    end
  end
end
