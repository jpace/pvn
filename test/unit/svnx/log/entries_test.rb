#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/tc'
require 'svnx/log/entries'

module SVNx::Log
  class EntriesTestCase < SVNx::Log::TestCase
    def assert_entry_fields_not_nil entry
      # these are occasionally missing or blank, which REXML considers nil:
      assert entry.message
      assert entry.author
    end

    def assert_log_entry_16 entry
      expdata = '16', 'Buddy Bizarre', '2012-09-16T14:07:30.329525Z', 'CUT! What in the hell do you think you\'re doing here? This is a closed set.'
      expdata << { :kind => 'dir', 
        :action => 'A', 
        :name => '/src/java'
      }
      expdata << { :kind => 'file', 
        :action => 'A', 
        :name => '/src/java/Alpha.java'
      }
      expdata << { :kind => 'file', 
        :action => 'A', 
        :name => '/src/java/Bravo.java'
      }
      
      assert_log_entry_equals entry, expdata
    end
    
    def test_create_from_xml
      # entries = Entries.new :xmllines => Resources::PT_LOG_L_15.readlines this
      # is the equivalent of being at revision 19 (when this was written) and
      # doing "svn log -r19:5"
      entries = Entries.new :xmllines => Resources::PT_LOG_R19_5.readlines
      assert_log_entry_16 entries[3]
    end
    
    def test_empty_message_element
      entries = Entries.new :xmllines => Resources::PT_LOG_R19.readlines
      nentries = entries.size
      
      # empty message here:
      assert_entry_fields_not_nil entries[0]
    end

    def test_create_on_demand
      # although entries now supports xmllines as an Array, we need the size for the assertion:
      xmllines = Resources::PT_LOG_R19_5.readlines
      
      assert_equal 101, xmllines.size

      entries = Entries.new :xmllines => xmllines

      nentries = entries.size
      assert_equal 15, nentries

      # the power of Ruby, effortlessly getting instance variables ...

      real_entries = entries.instance_eval '@entries'

      # nothing processed yet ...
      assert_nil real_entries[12]
      assert_nil real_entries[13]
      assert_nil real_entries[14]

      assert_entry_fields_not_nil entries[13]

      # and these still aren't processed:
      assert_nil real_entries[12]
      assert_nil real_entries[14]
    end

    def test_each
      idx = 0

      entries = Entries.new :xmllines => Resources::PT_LOG_R19_5.readlines
      entries.each do |entry|
        if idx == 3
          assert_log_entry_16 entry
        end
        idx += 1
      end
    end
  end
end
