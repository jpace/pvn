#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/xml/xmlentry'
require 'svnx/log/entry'

module SVNx
  module Log
    class Entries
      include Loggable

      attr_reader :entries
      
      def initialize args = Hash.new
        @entries = Array.new

        if xmllog = args[:xmllog]
          # info "xmllog: #{xmllog}".yellow

          xmllog.xmlentries.each do |xmlentry|
            # info "xmlentry: #{xmlentry.revision}"
            @entries << Entry.new(:xmlentry => xmlentry)
          end          
        end
      end
    end
  end
end
