#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'

module SVNx; module Info; end; end

module SVNx::Info
  class TestCase < PVN::TestCase
    include Loggable

    def assert_entry_equals entry, expdata
      info "entry: #{entry.inspect}"
      info "expdata: #{expdata.inspect}"

      [ :url, :path, :root, :kind ].each do |field|
        assert_equal expdata[field], entry.send(field)
      end
    end
  end
end
