#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/entry'

module SVNx; module Status; end; end

module SVNx::Status
  class Entry < SVNx::Entry

    attr_reader :status
    attr_reader :path
    
    def initialize args = Hash.new
      # this is status/target/entry from "svn status --xml <foo>"
      if xmlelement = args[:xmlelement]
        set_attr_var xmlelement, 'path'
        if wcstatus = xmlelement.elements['wc-status']
          @status = wcstatus.attributes['item']
        else
          @status = "unchanged"
        end
      elsif xmllines = args[:xmllines]
        doc    = REXML::Document.new xmllines
        stelmt = doc.elements['status']
        tgt    = stelmt.elements['target']

        set_attr_var tgt, 'path'
        
        if entry = tgt.elements['entry']
          wcstatus = entry.elements['wc-status']
          @status = wcstatus.attributes['item']
        else
          @status = "unchanged"
        end
      else
        raise "must be initialized with xmlelement or xmllines"
      end
    end
  end
end
