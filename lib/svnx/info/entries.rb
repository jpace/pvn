#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/info/entry'
require 'svnx/entries'

module SVNx::Info
  class Entries < SVNx::Entries
    def get_elements doc
      doc.elements['info'].elements
    end

    def create_entry xmlelement
      Entry.new :xmlelement => xmlelement
    end
  end
end
