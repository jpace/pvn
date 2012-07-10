#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/status/xml/xmlentry'
require 'svnx/status/entry'

module SVNx
  module Status
    class Entries
      include Loggable

      attr_reader :entries

      def initialize args = Hash.new
        @entries = Array.new

        if xmlstatus = args[:xmlstatus]
          xmlstatus.xmlentries.each do |xmlentry|
            @entries << Entry.new(:xmlentry => xmlentry)
          end
        end
      end
    end
  end
end
