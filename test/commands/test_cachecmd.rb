require File.dirname(__FILE__) + '/../test_helper.rb'

require 'rubygems'
require 'riel'
require 'commands/command_test'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module PVN
  class TestCommand < CommandTestCase
    include Loggable

    def test_cached_no_changes
      remove_cache_dir
      info "running first one ..."
      assert_svn_log true, true

      info "running second one ..."
      assert_svn_log false, true
    end

    def test_cached_different_arguments
      remove_cache_dir
      info "running first one ..."
      assert_svn_log true, true, [ '-l', 5 ]
      
      info "running second one ..."
      assert_svn_log true, true, [ '-l', 6 ]
    end

    def test_uncached_command
      remove_cache_dir
      info "running first one ..."
      assert_svn_log true, false
      
      info "running second one ..."
      assert_svn_log true, false
    end
  end
end
