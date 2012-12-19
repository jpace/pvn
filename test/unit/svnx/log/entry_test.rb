#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/tc'
require 'svnx/log/entry'

module SVNx::Log
  class EntryTestCase < SVNx::Log::TestCase
    def test_entry_from_xml
      doc = REXML::Document.new Resources::PT_LOG_R19_5.readlines.join('')
      entry = Entry.new :xmlelement => doc.elements[1].elements[4]
      assert_log_entry_16 entry
    end
  end
end
