#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/tc'
require 'svnx/log/entry'

module SVNx::Log
  class EntryTestCase < SVNx::Log::TestCase
    include Loggable
    
    def test_entry_from_xml
      expdata = '1947', 'reiern70', '2011-11-14T12:24:45.757124Z', 'added a convenience method to set the range'
      expdata << { :kind => 'file', :action => 'M', :name => '/trunk/wiquery-jquery-ui/src/test/java/org/odlabs/wiquery/ui/slider/SliderTestCase.java' }

      doc = REXML::Document.new test_lines_limit_15.join('')
      # info "doc: #{doc}"

      entry = Entry.new :xmlelement => doc.elements[1].elements[3]        
      assert_log_entry_equals entry, expdata
    end
  end
end
