#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn_test'
require 'pvn/svn/log/command'
require 'rexml/document'

module PVN
  module SVN
    class TestLogCommand < PVN::TestCase
      include Loggable

      def find_subelement_by_name elmt, name
        subelmt = elmt.elements.detect { |el| el.name == name }
        subelmt ? subelmt.get_text.to_s : nil
      end

      def assert_log_entry elmt, expdata = Hash.new
        assert_equals 'logentry', elmt.name

        info "elmt: #{elmt}"
        assert_equals expdata[:author], find_subelement_by_name(elmt, 'author')
        assert_equals expdata[:date], find_subelement_by_name(elmt, 'date')
        assert_equals expdata[:msg], find_subelement_by_name(elmt, 'msg')
      end

      def test_run
        Dir.chdir '/Programs/wiquery/trunk'
        
        cmd = LogCommand.new({ :use_cache => false })
        info "cmd: #{cmd}"
        # info "cmd.output: #{cmd.output}"

        doc = REXML::Document.new cmd.output.join ''
        # info "doc: #{doc}"

        elements = doc.elements

        assert_equals 1, elements.size

        # remember: 1-indexed
        logelmt = elements[1]

        assert_equals 'log', logelmt.name
        
        logentryelmts = logelmt.elements

        assert_equals 163, logentryelmts.size

        assert_log_entry logentryelmts[1], :author => 'jpace', :date => '2011-12-05T12:41:52.385786Z', :msg => 'Testing.'
        assert_log_entry logentryelmts[17], :author => 'hielke.hoeve@gmail.com', :date => '2011-09-28T14:32:43.601185Z', :msg => 'rework of the js/css/string tokens for post rendering.'
        
        # cmd = LogCommand.new({ :use_cache => true })
        # info "cmd: #{cmd}"
        
        # info "cmd.output: #{cmd.output}".blue
      end
    end
  end
end
