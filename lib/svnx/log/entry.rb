#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/xml/xmlentry'

module SVNx
  module Log
    class Entry
      include Loggable

      attr_reader :revision, :author, :date, :paths, :message
      
      def initialize args = Hash.new
        # this is log/logentry from "svn log --xml"
        if xmlelement = args[:xmlelement]
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
        elsif xmlentry = args[:xmlentry]
          @revision = xmlentry.revision
          @author = xmlentry.author
          @date = xmlentry.date
          @message = xmlentry.message
          @paths = xmlentry.paths
        else
          @revision = args[:revision]
          @author = args[:author]
          @date = args[:date]
          @paths = args[:paths]
          @message = args[:message]
        end

        # info "self: #{self.inspect}".red
      end

      def get_attribute xmlelement, attrname
        xmlelement.attributes[attrname]
      end

      def get_element_text xmlelement, elmtname
        xmlelement.elements[elmtname].text
      end
    end

    class LogEntryPath
      attr_reader :kind, :action, :name
      
      def initialize args = Hash.new
        @kind = args[:kind]
        @action = args[:action]
        @name = args[:name]
      end
    end
  end
end
