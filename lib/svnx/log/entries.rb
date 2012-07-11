#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/entry'

module SVNx
  module Log
    class Entries < Array
      include Loggable

      def initialize args = Hash.new
        if xmllines = args[:xmllines]
          info "xmllines: #{xmllines}"
        elsif xmlentries = args[:xmlentries]
          xmlentries.each do |xmlentry|
            self << Entry.new(:xmlentry => xmlentry)
          end
        end
      end
    end
  end
end
