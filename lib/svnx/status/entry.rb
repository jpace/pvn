#!/usr/bin/ruby -w
# -*- ruby -*-

# require 'svnx/status/xml/xmlentry'

module SVNx
  module Status
    class Entry
      include Loggable

      attr_reader :status
      
      def initialize args = Hash.new
        if xml = args[:xml]
          @status = xml.status
        else
          @status = args[:status]
        end

        info "self: #{self.inspect}".red
      end
    end
  end
end
