#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/info/tc'
require 'svnx/info/entries'

module SVNx::Info
  class EntriesTestCase < SVNx::Info::TestCase
    def assert_info_entry_equals entry, path, kind, revision
      assert_entry_equals entry, :path => path, :kind => 'file', :url => EXPROOT + '/' + path, :root => EXPROOT, :revision => revision
    end

    def test_create_from_xml
      entries = Entries.new :xmllines => Resources::PTP_INFO_SIXTH_TXT_DOG_RB_FIRST_TXT.readlines
      assert_equal 3, entries.size

      assert_info_entry_equals entries[0], 'dirzero/SixthFile.txt', 'file', '22'
      assert_info_entry_equals entries[1], 'src/ruby/dog.rb',       'file', '0'
      assert_info_entry_equals entries[2], 'FirstFile.txt',         'file', '22'
    end
  end
end
