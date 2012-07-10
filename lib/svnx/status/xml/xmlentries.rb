#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/status/entry'

module SVNx
  module Status
    class XMLEntries < Array
      include Loggable
      
      def initialize lines
        super()

        doc = REXML::Document.new lines

        # log/logentry
        doc.elements.each('status') do |elmt|
          info "elmt: #{elmt.class}".yellow
          self << XMLEntry.new(elmt)
        end
      end
    end
  end
end
