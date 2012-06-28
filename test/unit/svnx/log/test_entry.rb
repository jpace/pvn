#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn_test'
require 'svnx/log/entry'
require 'svnx/log/logdata'
require 'svnx/log/tc_log'
require 'rexml/document'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module PVN
  module SVN
    class TestLogEntry < PVN::TestCase
      include Loggable
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
      
      def test_entry_from_xml
        expdata = '1947', 'reiern70', '2011-11-14T12:24:45.757124Z', 'added a convenience method to set the range'
        expdata << { :kind => 'file', :action => 'M', :name => '/trunk/wiquery-jquery-ui/src/test/java/org/odlabs/wiquery/ui/slider/SliderTestCase.java' }

        doc = REXML::Document.new LogData::TEST_LINES.join('')
        info "doc: #{doc}"

        entries = Array.new

        # log/logentry
        xmlentry = doc.elements[1].elements[3]

        entry = Entry.create_from_xml_element xmlentry
        
        assert_entry_equals entry, expdata
      end
    end
  end
end
