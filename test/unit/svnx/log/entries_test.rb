#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/tc'
require 'svnx/log/entries'

module SVNx::Log
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
      
      entries = Entries.new :xmllines => get_test_lines_limit_15

      assert_log_entry_equals entries[2], expdata
    end

    def test_no_author_field
      entries = Entries.new :xmllines => get_test_lines_no_author
      nentries = entries.size

      # revision 1 has no author ... wtf?
      assert_entry_fields_not_nil entries[0]
    end

    def test_empty_message_element
      entries = Entries.new :xmllines => get_test_lines_empty_message
      nentries = entries.size

      # empty message here:
      assert_entry_fields_not_nil entries[0]
    end

    def test_create_on_demand
      # although entries now supports xmllines as an Array, we need the size for the assertion:
      xmllines = get_test_lines_no_limit.join ''
      
      # quite a big file ...
      assert_equal 324827, xmllines.size

      entries = Entries.new :xmllines => xmllines

      nentries = entries.size
      assert_equal 1949, nentries

      # the power of Ruby, effortlessly getting instance variables ...

      real_entries = entries.instance_eval '@entries'

      # nothing processed yet ...
      assert_nil real_entries[16]
      assert_nil real_entries[17]
      assert_nil real_entries[18]

      assert_entry_fields_not_nil entries[17]

      # and these still aren't processed:
      assert_nil real_entries[16]
      assert_nil real_entries[18]
    end
  end
end
