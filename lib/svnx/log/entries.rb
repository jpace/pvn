#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/entry'
require 'rexml/document'

module SVNx::Log
  class Entries
    include Loggable, Enumerable

    attr_reader :size

    def initialize args = Hash.new
      # it's a hash, but indexed with integers.
      @entries = Hash.new

      if xmllines = args[:xmllines]
        # this is preferred

        if xmllines.kind_of? Array
          xmllines = xmllines.join ''
        end

        doc = REXML::Document.new xmllines

        @logelements = doc.elements['log'].elements
        @size = @logelements.size
      elsif xmlentries = args[:xmlentries]
        # this is legacy:

        xmlentries.each do |xmlentry|
          @entries[@entries.size] = Entry.new(:xmlentry => xmlentry)
        end
      end
    end

    def [] idx
      @entries[idx] ||= Entry.new(:xmlelement => @logelements[idx + 1])
    end

    def each(&blk)
      # all elements must be processed before this can happen:
      if @logelements
        @logelements.each_with_index do |logelement, idx|
          # info "logelement: #{logelement}"
          # info "idx: #{idx}"
          @entries[idx] ||= Entry.new(:xmlelement => logelement)
        end

        @logelements = nil
      end

      @entries.keys.sort.collect { |idx| @entries[idx] }.each(&blk)
    end
  end
end
