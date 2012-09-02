#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/status/entry'
require 'svnx/entries'

module SVNx::Status
  class Entries < SVNx::Entries
    def get_elements doc
      doc.elements['status'].elements['target'].elements
    end

    def create_entry xmlelement
      Entry.new :xmlelement => xmlelement
    end
  end
end
