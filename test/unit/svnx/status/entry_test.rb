#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/status/tc'
require 'svnx/status/entry'

module SVNx::Status
  class EntryTestCase < SVNx::Status::TestCase
    def test_entry_from_xml
      entry = Entry.new :xmllines => Resources::PTP_STATUS_DOG_RB.readlines
      assert_status_entry_equals 'added', 'src/ruby/dog.rb', entry
    end
  end
end
