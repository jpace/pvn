#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'rexml/document'

module SVNx
  class Entry
    include Loggable

    def initialize args = Hash.new
      if xmllines = args[:xmllines]
        if xmllines.kind_of? Array
          xmllines = xmllines.join ''
        end

        doc = REXML::Document.new xmllines

        set_from_xml doc
      elsif elmt = args[:xmlelement]
        set_from_element elmt
      else
        raise "must be initialized with xmllines or xmlelement"
      end
    end

    def set_from_xml xmldoc
      raise "must be implemented"
    end

    def set_from_element elmt
      raise "must be implemented"
    end

    def get_attribute xmlelement, attrname
      xmlelement.attributes[attrname]
    end

    def get_element_text xmlelement, elmtname
      elmt = xmlelement.elements[elmtname]
      # in my test svn repository, revision 1 doesn't have an author element:
      (elmt && elmt.text) || ""
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
end
