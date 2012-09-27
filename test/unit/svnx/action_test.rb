#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'svnx/action'

module SVNx
  class ActionTestCase < PVN::TestCase
    include Loggable

    def assert_action_added exp, str
      action = Action.new str
      assert_equal exp, action.added?
    end

    def assert_action_deleted exp, str
      action = Action.new str
      assert_equal exp, action.deleted?
    end

    def assert_action_modified exp, str
      action = Action.new str
      assert_equal exp, action.modified?
    end

    def assert_action_unversioned exp, str
      action = Action.new str
      assert_equal exp, action.unversioned?
    end
    
    def test_added
      [ 'added', 'A' ].each do |str|
        assert_action_added       true,  str
        assert_action_deleted     false, str
        assert_action_modified    false, str
        assert_action_unversioned false, str
      end
    end
    
    def test_deleted
      [ 'deleted', 'D' ].each do |str|
        assert_action_added       false, str
        assert_action_deleted     true,  str
        assert_action_modified    false, str
        assert_action_unversioned false, str
      end
    end
    
    def test_modified
      [ 'modified', 'M' ].each do |str|
        assert_action_added       false, str
        assert_action_deleted     false,  str
        assert_action_modified    true,  str
        assert_action_unversioned false, str
      end
    end    
    
    def test_unversioned
      [ 'unversioned', '?' ].each do |str|
        assert_action_added       false, str
        assert_action_deleted     false, str
        assert_action_modified    false, str
        assert_action_unversioned true, str
      end
    end
  end
end
