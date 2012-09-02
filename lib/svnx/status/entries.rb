#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/status/entry'

module SVNx::Status
  class Entries
    include Loggable

    def initialize args = Hash.new
      @entries = Hash.new
      
      if xmllines = args[:xmllines]
        if xmllines.kind_of? Array
          xmllines = xmllines.join ''
        end

        doc = REXML::Document.new xmllines

        info "doc: #{doc}".yellow
        @elements = doc.elements['status'].elements['target'].elements
        info "stati: #{@elements}"
        @elements.each do |elmt|
          info "elmt: #{elmt}"
        end

        @size = @elements.size
        info "size: #{@size}"

        # raise "not implemented"
        
        # if xmlentries = args[:xml]
        #   xmlentries.each do |xmlentry|
        #     self << Entry.new(:xml => xmlentry)
        #   end
      end
    end

    def [] idx
      @entries[idx] ||= Entry.new(:xmlelement => @elements[idx + 1])
    end
  end
end
