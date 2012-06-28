#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/xmlentry'

module PVN
  module SVN
    class Entry
      include Loggable

      class << self
        def create_from_xml_element xmlelement
          entry = XMLEntry.new xmlelement
          new({ :revision => entry.revision, :author => entry.author, :date => entry.date, :message => entry.message, :paths => entry.paths })
        end
      end

      LOG_SUMMARY_RE = Regexp.new '^r(\d+) \| (\S+) \| (\S+) (\S+) (\S+) \((.*)\) \| (\d+) lines?$'

      attr_reader :revision, :author, :date, :paths, :message
      
      def initialize args = Hash.new
        @revision = args[:revision]
        @author = args[:author]
        @date = args[:date]
        @paths = args[:paths]
        @message = args[:message]
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
