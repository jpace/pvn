#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/tc'
require 'svnx/log/entry'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module SVNx
  module Log
    class EntryTestCase < SVNx::Log::TestCase
      include Loggable
      
      def test_entry_from_xml
        expdata = '1947', 'reiern70', '2011-11-14T12:24:45.757124Z', 'added a convenience method to set the range'
        expdata << { :kind => 'file', :action => 'M', :name => '/trunk/wiquery-jquery-ui/src/test/java/org/odlabs/wiquery/ui/slider/SliderTestCase.java' }

        doc = REXML::Document.new LogData::TEST_LINES.join('')
        info "doc: #{doc}"

        entries = Array.new

        # log/logentry
        xmlentry = XMLEntry.new doc.elements[1].elements[3]

        entry = Entry.new :xmlentry => xmlentry
        
        assert_entry_equals entry, expdata
      end
    end
  end
end
