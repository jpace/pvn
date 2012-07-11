#!/usr/bin/ruby -w
# -*- ruby -*-

module SVNx
  module Log
    class Entry
      include Loggable

      attr_reader :revision, :author, :date, :paths
      
      def initialize args = Hash.new
        # this is log/logentry from "svn log --xml"
        if xmlelement = args[:xmlelement]
          set_attr_var xmlelement, 'revision'

          %w{ author date msg }.each do |field|
            set_elmt_var xmlelement, field
          end
          
          @paths = Array.new

          xmlelement.elements.each('paths/path') do |pe|
            kind = get_attribute pe, 'kind'
            action = get_attribute pe, 'action'
            name = pe.text

            @paths << LogEntryPath.new(:kind => kind, :action => action, :name => name)
          end
        else
          @revision = args[:revision]
          @author = args[:author]
          @date = args[:date]
          @paths = args[:paths]
          @message = args[:message]
        end
      end

      def message
        @msg
      end

      def get_attribute xmlelement, attrname
        xmlelement.attributes[attrname]
      end

      def get_element_text xmlelement, elmtname
        xmlelement.elements[elmtname].text
      end

      def set_attr_var xmlelement, varname
        set_var varname, get_attribute(xmlelement, varname)
      end

      def set_elmt_var xmlelement, varname
        set_var varname, get_element_text(xmlelement, varname)
      end

      def set_var varname, value
        instance_variable_set '@' + varname, value
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
