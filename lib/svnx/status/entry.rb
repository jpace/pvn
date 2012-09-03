#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/entry'

module SVNx; module Status; end; end

module SVNx::Status
  class Entry < SVNx::Entry

    attr_reader :status
    attr_reader :path

    def set_from_xml xmldoc
      stelmt = xmldoc.elements['status']
      tgt    = stelmt.elements['target']

      info "tgt: #{tgt}".yellow

      set_attr_var tgt, 'path'      
      if entry = tgt.elements['entry']
        wcstatus = entry.elements['wc-status']
        @status = wcstatus.attributes['item']
      else
        @status = "unchanged"
      end
    end

    def set_from_element elmt
      set_attr_var elmt, 'path'
      if wcstatus = elmt.elements['wc-status']
        @status = wcstatus.attributes['item']
      else
        @status = "unchanged"
      end
    end
  end
end
