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
        
        entries = Entries.new :xmllines => test_lines_limit_15.join('')

        assert_log_entry_equals entries[2], expdata
      end

      def test_no_author_field
        entries = Entries.new :xmllines => test_lines_no_author.join('')
        nentries = entries.size

        # revision 1 has no author ... wtf?
        assert_entry_fields_not_nil entries[0]
      end

      def test_empty_message_element
        entries = Entries.new :xmllines => test_lines_empty_message.join('')
        nentries = entries.size

        # empty message here:
        assert_entry_fields_not_nil entries[0]
      end

      def test_create_on_demand
        xmllines = test_lines_no_limit.join('')

        info "xmllines #{xmllines.size} fetched."

        assert_equal 324827, xmllines.size

        entries = Entries.new :xmllines => xmllines

        nentries = entries.size
        assert_equal 1949, nentries

        # the power of Ruby, effortlessly getting instance variables ...

        real_entries = entries.instance_eval '@entries'

        assert_nil real_entries[16]
        assert_nil real_entries[17]
        assert_nil real_entries[18]

        assert_entry_fields_not_nil entries[17]

        assert_nil real_entries[16]
        assert_nil real_entries[18]
      end
    end
  end
end
