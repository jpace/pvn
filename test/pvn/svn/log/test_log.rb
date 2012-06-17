#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn_test'
require 'pvn/svn/log/entry'
require 'pvn/svn/log/xmllog'
require 'pvn/svn/log/logdata'
require 'rexml/document'

module PVN
  module SVN
    class TestLogEntry < PVN::TestCase
      include Loggable

      def assert_entry_equals entry, expdata
        assert_equals expdata[0], entry.revision
        assert_equals expdata[1], entry.author
        assert_equals expdata[2], entry.date
        assert_equals expdata[3], entry.message
        entry.paths.each_with_index do |path, idx|
          info path.inspect.yellow
          assert_equals expdata[4 + idx][:kind], path.kind
          assert_equals expdata[4 + idx][:action], path.action
          assert_equals expdata[4 + idx][:name], path.name
        end
      end
      
      def test_entries_from_xml
        expdata = '1947', 'reiern70', '2011-11-14T12:24:45.757124Z', 'added a convenience method to set the range'
        expdata << { :kind => 'file', :action => 'M', :name => '/trunk/wiquery-jquery-ui/src/test/java/org/odlabs/wiquery/ui/slider/SliderTestCase.java' }

        # /log (remember, they're 1-indexed in the XML world. of course.)
        xmllog = XMLLog.new LogData::TEST_LINES.join('')
        info "xmllog: #{xmllog}".on_blue
        
        xmllog.xmlentries.each do |xmlentry|
          info "xmlentry: #{xmlentry}"
        end

        # entry = Entry.create_from_xml_element xmllog.xmlentries[2]

        assert_entry_equals xmllog.xmlentries[2], expdata
      end
    end
  end
end
