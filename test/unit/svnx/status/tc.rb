#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'resources'

module SVNx; module Status; end; end

module SVNx::Status
  class TestCase < PVN::TestCase
    def find_subelement_by_name elmt, name
      subelmt = elmt.elements.detect { |el| el.name == name }
      subelmt ? subelmt.get_text.to_s : nil
    end

    def assert_status_entry_equals exp_status, exp_path, entry
      assert_equal exp_status, entry.status
      assert_equal exp_path, entry.path
    end
  end
end
