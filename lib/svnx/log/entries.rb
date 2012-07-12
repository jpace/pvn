#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/entry'
require 'rexml/document'

module SVNx
  module Log
    class Entries < Array
      include Loggable

      def initialize args = Hash.new
        # this is preferred
        if xmllines = args[:xmllines]
          info "xmllines: #{xmllines}"
          doc = REXML::Document.new xmllines

          # log/logentry
          doc.elements.each('log/logentry') do |logentry|
            self << Entry.new(:xmlelement => logentry)
          end
          # this is legacy:
        elsif xmlentries = args[:xmlentries]
          xmlentries.each do |xmlentry|
            self << Entry.new(:xmlentry => xmlentry)
          end
        end
      end
    end
  end
end
