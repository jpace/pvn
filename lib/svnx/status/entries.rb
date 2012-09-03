#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/status/entry'
require 'svnx/entries'

module SVNx::Status
  class Entries < SVNx::Entries
    def get_elements doc
      info "doc: #{doc}".cyan
      doc.elements['status'].elements['target'].elements
    end

    def create_entry xmlelement
      info "xmlelement: #{xmlelement}".cyan
      Entry.new :xmlelement => xmlelement
    end
  end
end
