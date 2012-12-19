#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'resources'

module SVNx; module Info; end; end

module SVNx::Info
  class TestCase < PVN::TestCase
    EXPROOT = 'file:///Programs/Subversion/Repositories/pvntestbed.from'

    def assert_entry_equals entry, expdata
      [ :url, :path, :root, :kind, :revision ].each do |field|
        assert_equal expdata[field], entry.send(field)
      end
    end
  end
end
