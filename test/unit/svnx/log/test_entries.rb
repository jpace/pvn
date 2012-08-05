#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/tc'
require 'svnx/log/entries'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module SVNx
  module Log
    class EntriesTestCase < SVNx::Log::TestCase
      include Loggable

      def assert_entry_fields_not_nil entry
        debug "entry: #{entry}".bold
        debug "entry.revision: #{entry.revision}".bold
        debug "entry.author: #{entry.author}".bold
        debug "entry.message: #{entry.message.inspect}".bold

        # these are occasionally missing or blank, which REXML considers nil:
        assert entry.message
        assert entry.author
      end
      
      def test_create_from_xml
        expdata = '1947', 'reiern70', '2011-11-14T12:24:45.757124Z', 'added a convenience method to set the range'
        expdata << { :kind => 'file', 
          :action => 'M', 
          :name => '/trunk/wiquery-jquery-ui/src/test/java/org/odlabs/wiquery/ui/slider/SliderTestCase.java'
        }
        
        entries = Entries.new :xmllines => test_lines.join('')

        assert_log_entry_equals entries[2], expdata
      end

      def test_create_from_long_xml
        entries = Entries.new :xmllines => test_lines_no_limit.join('')
        nentries = entries.size

        # these are occasionally missing or blank, which REXML considers nil:
        
        # empty message here:
        assert_entry_fields_not_nil entries[201]

        # first entry (revision 1) has no author ... wtf?
        assert_entry_fields_not_nil entries[1948]
      end
    end
  end
end
