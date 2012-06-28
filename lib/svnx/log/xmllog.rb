#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rexml/document'
require 'svnx/log/xmlentry'

module PVN
  module SVN
    class XMLLog < REXML::Document
      include Loggable
      
      attr_reader :xmlentries
      
      def initialize lines
        super

        @xmlentries = Array.new

        # log/logentry
        elements.each('log/logentry') do |entryelement|
          info "entryelement: #{entryelement.class}".yellow
          @xmlentries << XMLEntry.new(entryelement)
        end
      end
    end
  end
end