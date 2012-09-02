#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/status/tc'
require 'svnx/status/entries'

module SVNx::Status
  class EntriesTestCase < SVNx::Status::TestCase
    
    def test_create_from_xml
      entries = Entries.new :xmllines => get_test_lines_all

      assert_equal 4, entries.size
      assert_status_entry_equals 'added',   'Orig.java', entries[0]
      assert_status_entry_equals 'deleted', 'LICENSE', entries[1]
      assert_status_entry_equals 'modified', 'pom.xml', entries[2]
      assert_status_entry_equals 'modified', 'wiquery-core/src/main/java/org/odlabs/wiquery/core/effects/EffectBehavior.java', entries[3]
    end
  end
end
