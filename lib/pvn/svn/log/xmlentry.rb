#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/svn/log/entry'

module PVN
  module SVN
    class XMLEntry
      include Loggable

      attr_reader :revision, :author, :date, :paths, :message
      
      # this is log/logentry from "svn log -v (optional) --xml"
      def initialize xmlelement
        @revision = get_attribute xmlelement, 'revision'
        @author = get_element_text xmlelement, 'author'
        @date = get_element_text xmlelement, 'date'
        @message = get_element_text xmlelement, 'msg'

        @paths = Array.new

        xmlelement.elements.each('paths/path') do |pe|
          kind = get_attribute pe, 'kind'
          action = get_attribute pe, 'action'
          name = pe.text

          @paths << LogEntryPath.new(:kind => kind, :action => action, :name => name)
        end
      end

      def get_attribute xmlentry, attrname
        xmlentry.attributes[attrname]
      end

      def get_element_text xmlentry, elmtname
        xmlentry.elements[elmtname].text
      end
    end
  end
end