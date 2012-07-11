#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/entry'

module SVNx
  module Log
    class Entries < Array
      include Loggable

      def initialize xmlentries
        xmlentries.each do |xmlentry|
          self << Entry.new(:xmlentry => xmlentry)
        end
      end
    end
  end
end
