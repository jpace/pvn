#!/usr/bin/ruby -w
# -*- ruby -*-

require 'integration/tc'
require 'svnx/log/tc'
require 'svnx/log/command'
require 'svnx/log/entry'

module SVNx
  module Log
    class EntryTestCase < PVN::IntegrationTestCase
      include Loggable

      def assert_log_entry_equals entry, expdata
        assert_equal expdata[0], entry.revision
        assert_equal expdata[1], entry.author
        assert_equal expdata[2], entry.date
        assert_equal expdata[3], entry.message
        entry.paths.each_with_index do |path, idx|
          info path.inspect.yellow
          assert_equal expdata[4 + idx][:kind], path.kind
          assert_equal expdata[4 + idx][:action], path.action
          assert_equal expdata[4 + idx][:name], path.name
        end
      end
      
      def test_entry_from_command
        lcargs = LogCommandArgs.new :limit => 2, :verbose => false, :use_cache => false
        lc = LogCommand.new lcargs
        
        lc.execute
        output = lc.output
        info "output: #{output}"
        
        expdata = '1947', 'reiern70', '2011-11-14T12:24:45.757124Z', 'added a convenience method to set the range'
        expdata << { :kind => 'file', :action => 'M', :name => '/trunk/wiquery-jquery-ui/src/test/java/org/odlabs/wiquery/ui/slider/SliderTestCase.java' }

        doc = REXML::Document.new output.join('')

        entry = Entry.new :xmlelement => doc.elements[1].elements[2]
        assert_log_entry_equals entry, expdata
      end
    end
  end
end
