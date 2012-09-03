#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'resources'

module SVNx; module Info; end; end

module SVNx::Info
  class TestCase < PVN::TestCase
    include Loggable

    def get_test_lines(*args)
      Resources.instance.test_lines '/Programs/wiquery/trunk', 'svn', 'info', '--xml', *args
    end
    
    def get_test_lines_one_entry
      get_test_lines 'wiquery-core/pom.xml'
    end

    def get_test_lines_two_entries
      get_test_lines 'pom.xml', 'Orig.java'
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
