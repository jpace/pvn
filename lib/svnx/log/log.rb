#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/xml/xmlentry'

module PVN
  module SVN
    class Log
      include Loggable

      class << self
        def create_from_xml_element xmlelement
          xmllog = XMLLog.new xmlelement
          entry = XMLEntry.new xmlelement
          new ({ :revision => entry.revision, :author => entry.author, :date => entry.date, :message => entry.message, :paths => entry.paths })
        end
      end

      attr_reader :entries
      
      def initialize args = Hash.new
        @entries = args[:entries]
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
