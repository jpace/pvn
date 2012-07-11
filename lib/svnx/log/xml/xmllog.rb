#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rexml/document'
require 'svnx/log/xml/xmlentry'

module SVNx
  module Log
    class XMLEntries < Array
      include Loggable
      
      def initialize lines
        doc = REXML::Document.new lines

        # log/logentry
        doc.elements.each('log/logentry') do |entryelement|
          self << XMLEntry.new(entryelement)
        end
      end
    end
  end
end
