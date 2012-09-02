#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/status/tc'
require 'svnx/status/entry'

module SVNx::Status
  class EntryTestCase < SVNx::Status::TestCase
    include Loggable
    
    def test_entry_from_xml
      xml = Array.new
      xml << "<?xml version=\"1.0\"?>\n"
      xml << "<status>\n"
      xml << "<target\n"
      xml << "   path=\"LICENSE\">\n"
      xml << "<entry\n"
      xml << "   path=\"LICENSE\">\n"
      xml << "<wc-status\n"
      xml << "   props=\"none\"\n"
      xml << "   item=\"deleted\"\n"
      xml << "   revision=\"1950\">\n"
      xml << "<commit\n"
      xml << "   revision=\"412\">\n"
      xml << "<author>lionel.armanet</author>\n"
      xml << "<date>2010-09-17T21:23:25.763385Z</date>\n"
      xml << "</commit>\n"
      xml << "</wc-status>\n"
      xml << "</entry>\n"
      xml << "</target>\n"
      xml << "</status>\n"

      entry = Entry.new :xmllines => xml.join('')
      assert_status_entry_equals 'deleted', 'LICENSE', entry
    end
  end
end
