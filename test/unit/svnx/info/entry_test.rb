#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/info/tc'
require 'svnx/info/entry'

module SVNx::Info
  class EntryTestCase < SVNx::Info::TestCase
    def assert_info_entry_equals entry, path, kind, revision
      assert_entry_equals entry, :path => path, :kind => 'file', :url => EXPROOT + '/' + path, :root => EXPROOT, :revision => revision
    end

    def test_entry_from_xml
      xmllines = Resources::PTP_INFO_SIXTH_TXT.readlines

      entry = Entry.new :xmllines => xmllines
      assert_info_entry_equals entry, 'dirzero/SixthFile.txt', 'file', '22'
    end
  end
end
