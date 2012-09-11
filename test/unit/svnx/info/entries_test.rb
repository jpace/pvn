#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/info/tc'
require 'svnx/info/entries'

module SVNx::Info
  class EntriesTestCase < SVNx::Info::TestCase
    
    def test_create_from_xml
      entries = Entries.new :xmllines => Resources::WIQTR_INFO_POM_XML_ADDED_FILE_TXT.readlines
      info "entries: #{entries}"

      assert_equal 2, entries.size

      exproot = 'file:///home/jpace/Programs/Subversion/Repositories/wiquery'

      assert_entry_equals entries[0], :path => 'pom.xml',   :kind => 'file', :url => exproot + '/trunk/pom.xml',   :root => exproot, :revision => '1950'
      assert_entry_equals entries[1], :path => 'AddedFile.txt', :kind => 'file', :url => exproot + '/trunk/AddedFile.txt', :root => exproot, :revision => '0'
    end
  end
end
