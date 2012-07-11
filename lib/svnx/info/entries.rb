#!/usr/bin/ruby -w
# -*- ruby -*-

# require 'svnx/info/xml/xmlentry'
# require 'svnx/info/entry'

module SVNx
  module Info
    class Entries
      include Loggable

      attr_reader :entries
      
      def initialize args = Hash.new
        @entries = Array.new

        if xml = args[:xml]
          xml.xmlentries.each do |xmlentry|
            @entries << Entry.new(:xmlentry => xmlentry)
          end          
        end
      end
    end
  end
end
