#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/entry'

module SVNx
  class XMLEntry
    include Loggable

    attr_reader :revision, :author, :date, :paths, :message
    
    # this is log/logentry from "svn log --xml"
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

    def get_attribute xmlelement, attrname
      xmlelement.attributes[attrname]
    end

    def get_element_text xmlelement, elmtname
      xmlelement.elements[elmtname].text
    end
  end
end
