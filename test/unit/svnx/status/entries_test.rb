#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/status/tc'
require 'svnx/status/entries'

module SVNx::Status
  class EntriesTestCase < SVNx::Status::TestCase

    def assert_entry_fields_not_nil entry
      # these are occasionally missing or blank, which REXML considers nil:
      assert entry.message
      assert entry.author
    end
    
    def test_create_from_xml
      entries = Entries.new :xmllines => get_test_lines_all
      info "entries: #{entries}".blue

      assert_status_entry_equals 'modified', 'pom.xml', entries[2]
    end
  end
end
