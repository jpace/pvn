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

      set_attr_var tgt, 'path'      
      @status = if entry = tgt.elements['entry']
                  wcstatus = entry.elements['wc-status']
                  wcstatus.attributes['item']
                else
                  "unchanged"
                end
    end

    def set_from_element elmt
      set_attr_var elmt, 'path'
      @status = if wcstatus = elmt.elements['wc-status']
                  wcstatus.attributes['item']
                else
                  "unchanged"
                end
    end

    def to_s
      "path: #{@path}; status: #{@status}"
    end
  end
end
