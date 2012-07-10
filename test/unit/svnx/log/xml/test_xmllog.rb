#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/tc'
require 'svnx/log/xml/xmllog'

module SVNx
  module Log
    module XML
      class LogTestCase < SVNx::Log::TestCase
        include Loggable
        
        def test_create_from_xml
          expdata = '1947', 'reiern70', '2011-11-14T12:24:45.757124Z', 'added a convenience method to set the range'
          expdata << { :kind => 'file', :action => 'M', :name => '/trunk/wiquery-jquery-ui/src/test/java/org/odlabs/wiquery/ui/slider/SliderTestCase.java' }

          # /log (remember, they're 1-indexed in the XML world. of course.)
          xmllog = SVNx::Log::XMLEntries.new LogData::TEST_LINES.join('')
          
          assert_entry_equals xmllog.xmlentries[2], expdata
        end
      end
    end
  end
end
