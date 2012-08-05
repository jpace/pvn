#!/usr/bin/ruby -w
# -*- ruby -*-

require 'integration/tc'
require 'svnx/log/tc'
require 'svnx/log/command'
require 'svnx/log/entry'

module SVNx
  module Log
    class EntryTestCase < SVNx::TestCase
      include Loggable
      
      def test_entry_from_command
        lcargs = LogCommandArgs.new :limit => 1, :verbose => false, :use_cache => false
        info "lcargs: #{lcargs}"

        lc = LogCommand.new lcargs
        info "lc: #{lc}"

        lc.execute
        output = lc.output
        info "output: #{output}"
        
        expdata = '1947', 'reiern70', '2011-11-14T12:24:45.757124Z', 'added a convenience method to set the range'
        expdata << { :kind => 'file', :action => 'M', :name => '/trunk/wiquery-jquery-ui/src/test/java/org/odlabs/wiquery/ui/slider/SliderTestCase.java' }

        doc = REXML::Document.new output.join('')
        info "doc: #{doc}"

        entry = Entry.new :xmlelement => doc.elements[1].elements[3]        
        assert_entry_equals entry, expdata
      end
    end
  end
end
