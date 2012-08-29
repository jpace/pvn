#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'svnx/log/command'
require 'rexml/document'
require 'resources'

module SVNx::Log
  class TestCase < PVN::TestCase
    include Loggable

    def get_test_lines(*args)
      Resources.instance.test_lines '/Programs/wiquery', *args
    end
    
    def get_test_lines_limit_15
      get_test_lines 'svn', 'log', '-l', '15', '--xml'
    end

    def get_test_lines_no_limit
      get_test_lines 'svn', 'log', '--xml'
    end

    def get_test_lines_no_author
      get_test_lines 'svn', 'log', '-r1', '--xml'
    end

    def get_test_lines_empty_message
      get_test_lines 'svn', 'log', '-r1748', '--xml'
    end

    def find_subelement_by_name elmt, name
      subelmt = elmt.elements.detect { |el| el.name == name }
      subelmt ? subelmt.get_text.to_s : nil
    end

    def assert_log_entry_equals entry, expdata
      assert_equal expdata[0], entry.revision
      assert_equal expdata[1], entry.author
      assert_equal expdata[2], entry.date
      assert_equal expdata[3], entry.message
      entry.paths.each_with_index do |path, idx|
        assert_equal expdata[4 + idx][:kind], path.kind
        assert_equal expdata[4 + idx][:action], path.action
        assert_equal expdata[4 + idx][:name], path.name
      end
    end
  end
end
