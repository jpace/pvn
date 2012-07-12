#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/tc'
require 'rexml/document'

module SVNx
  module Status
    class TestCase < PVN::TestCase
      include Loggable

      def assert_entry_equals entry, expdata
        info "entry: #{entry.inspect}"
        info "expdata: #{expdata.inspect}"

        assert_equal expdata[:path], entry.path
        assert_equal expdata[:status], entry.status
      end
    end
  end
end
