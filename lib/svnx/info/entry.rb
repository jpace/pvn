#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/entry'

module SVNx
  module Info
    class Entry < SVNx::Entry

      attr_reader :url
      attr_reader :root
      attr_reader :kind
      attr_reader :path
      
      def initialize args = Hash.new
        if xmllines = args[:xmllines]
          doc    = REXML::Document.new xmllines
          entry = doc.elements['info/entry']

          set_attr_var entry, 'kind'
          set_attr_var entry, 'path'

          info "entry: #{entry}".green

          set_elmt_var entry, 'url'
          repo = entry.elements['repository']

          set_elmt_var repo, 'root'
        else
          raise "must be initialized with xmllines"
        end

        info "self: #{self.inspect}".red
      end
    end
  end
end
