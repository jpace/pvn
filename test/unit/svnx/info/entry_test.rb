#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/info/tc'
require 'svnx/info/entry'

module SVNx::Info
  class EntryTestCase < SVNx::Info::TestCase
    include Loggable
    def test_entry_from_xml
      xmllines = Resources::WIQTR_INFO_WIQUERY_CORE_POM_XML.readlines
      
      expdata = {
        :url  => 'file:///home/jpace/Programs/Subversion/Repositories/wiquery/trunk/wiquery-core/pom.xml',
        :kind => 'file',
        :path => 'wiquery-core/pom.xml',
        :root => 'file:///home/jpace/Programs/Subversion/Repositories/wiquery',
        :revision => '1950'
      }

      entry = Entry.new :xmllines => xmllines
      assert_entry_equals entry, expdata
    end
  end
end
