#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'rexml/document'

module SVNx
  class Entry
    include Loggable

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
end
