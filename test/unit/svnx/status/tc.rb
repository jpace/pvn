#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'

module SVNx; module Status; end; end

module SVNx::Status
  class TestCase < PVN::TestCase
    include Loggable

    def assert_entry_equals entry, expdata
      [ :path, :status ].each do |field|
        assert_equal expdata[field], entry.send(field)
      end
    end
  end
end
