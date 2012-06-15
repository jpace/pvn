#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'rexml/document'
require 'pvn/svn/log/xmlentry'

module PVN
  module SVN
    class XMLLog < REXML::Document
      attr_reader :entries
      
      def initialize lines
        super

        @entries = Array.new

        # log/logentry
        elements.each('log/logentry') do |entryelement|
          @entries << XMLEntry.new entryelement
        end
      end
    end
  end
end
