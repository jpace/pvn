#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/entries'
require 'svnx/log/entry'

module SVNx::Log
  class Entries < SVNx::Entries
    def get_elements doc
      doc.elements['log'].elements
    end

    def create_entry xmlelement
      Entry.new :xmlelement => xmlelement
    end
  end
end
