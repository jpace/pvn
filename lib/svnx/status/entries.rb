#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/status/entry'

module SVNx::Status
  class Entries < Array
    include Loggable

    def initialize args = Hash.new
      super()

      raise "not implemented"

      if xmlentries = args[:xml]
        xmlentries.each do |xmlentry|
          self << Entry.new(:xml => xmlentry)
        end
      end
    end
  end
end
