#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/status/entry'

module SVNx
  module Status
    class XMLEntry
      include Loggable

      attr_reader :status
      
      # this is status from "svn status --xml"
      def initialize xmlelement
        info "xmlelement: #{xmlelement}"

        target = xmlelement.elements['target']
        
        if entry = target.elements['entry']
          wcstatus = entry.elements['wc-status']
          @status  = wcstatus.attributes['item']
        else
          @status = "unchanged"
        end
      end
    end
  end
end
