#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/entry'

module SVNx; module Status; end; end

module SVNx::Status
  class Entry < SVNx::Entry

    attr_reader :status
    attr_reader :path
    
    def initialize args = Hash.new
      if xmllines = args[:xmllines]
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
        raise "must be initialized with xmllines"
      end
    end
  end
end
