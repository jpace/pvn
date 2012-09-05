#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'resources'

module SVNx; module Info; end; end

module SVNx::Info
  class TestCase < PVN::TestCase
    include Loggable

    def get_test_lines_one_entry
      Resources::WIQTR_INFO_WIQUERY_CORE_POM_XML.readlines
    end

    def get_test_lines_two_entries
      Resources::WIQTR_INFO_POM_XML_ORIG_JAVA.readlines
    end

    def assert_entry_equals entry, expdata
      info "entry: #{entry.inspect}"
      info "expdata: #{expdata.inspect}"

      [ :url, :path, :root, :kind ].each do |field|
        assert_equal expdata[field], entry.send(field)
      end
    end
  end
end
