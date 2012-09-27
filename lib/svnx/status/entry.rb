#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/entry'
require 'svnx/action'

module SVNx; module Status; end; end

module SVNx::Status
  class Entry < SVNx::Entry

    attr_reader :status
    attr_reader :path
    attr_reader :status_revision
    attr_reader :action

    def initialize args = Hash.new
      super
      @action = SVNx::Action.new @status
    end

    def set_from_xml xmldoc
      stelmt = xmldoc.elements['status']
      tgt    = stelmt.elements['target']
      
      set_attr_var tgt, 'path'
      
      if entry = tgt.elements['entry']
        set_from_element entry
      else
        @status = "unchanged"
      end
    end

    def set_from_element elmt
      set_attr_var elmt, 'path'

      wcstatus = elmt.elements['wc-status']
      @status = wcstatus.attributes['item']
      @status_revision = wcstatus.attributes['revision']
      
      if commit = wcstatus.elements['commit']
        @commit_revision = commit.attributes['revision']
      else
        @commit_revision = nil
      end
    end

    def to_s
      "path: #{@path}; status: #{@status}"
    end
  end
end
