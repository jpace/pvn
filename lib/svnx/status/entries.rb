#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/status/xml/xmlentry'
require 'svnx/status/entry'

module SVNx
  module Status
    class Entries < Array
      include Loggable

      def initialize args = Hash.new
        super()

        if xmlentries = args[:xml]
          xmlentries.each do |xmlentry|
            self << Entry.new(:xml => xmlentry)
          end
        end
      end
    end
  end
end
