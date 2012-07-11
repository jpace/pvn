#!/usr/bin/ruby -w
# -*- ruby -*-

# require 'svnx/info/xml/xmlentry'
# require 'svnx/info/entry'

module SVNx
  module Info
    class Entries < Array
      include Loggable

      def initialize args = Hash.new
        if xmllines = args[:xmllines]
          doc = REXML::Document.new xmllines

          # xxx
          doc.elements.each('xxx') do |entryelement|
            self << Entry.new(:xmlelement => entryelement)
          end
        elsif xml = args[:xml]
          xml.xmlentries.each do |xmlentry|
            self << Entry.new(:xmlentry => xmlentry)
          end          
        end
      end
    end
  end
end
