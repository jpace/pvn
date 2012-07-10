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

        if xmlentries = args[:xml]
          xmlentries.each do |xmlentry|
            @entries << Entry.new(:xml => xmlentry)
            info "@entries: #{@entries}".on_red
          end
        end
      end
    end
  end
end
