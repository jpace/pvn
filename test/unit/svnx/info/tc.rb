#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/tc'
require 'rexml/document'

module SVNx
  module Info
    class TestCase < PVN::TestCase
      include Loggable

      def assert_entry_equals entry, expdata
        info "entry: #{entry.inspect}"
        info "expdata: #{expdata.inspect}"

        assert_equal expdata[:url], entry.url
        assert_equal expdata[:path], entry.path
        assert_equal expdata[:root], entry.root
        assert_equal expdata[:kind], entry.kind
      end
    end
  end
end
