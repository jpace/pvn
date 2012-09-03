#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/info/tc'
require 'svnx/info/entries'

module SVNx::Info
  class EntriesTestCase < SVNx::Info::TestCase
    
    def test_create_from_xml
      entries = Entries.new :xmllines => get_test_lines_two_entries
      info "entries: #{entries}"

      assert_equal 2, entries.size

      exproot = 'file:///home/jpace/Programs/Subversion/Repositories/wiquery'

      assert_entry_equals entries[0], :path => 'pom.xml',   :kind => 'file', :url => exproot + '/trunk/pom.xml',   :root => exproot
      assert_entry_equals entries[1], :path => 'Orig.java', :kind => 'file', :url => exproot + '/trunk/Orig.java', :root => exproot
    end
  end
end
