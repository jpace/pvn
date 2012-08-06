#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/entry'
require 'rexml/document'

module SVNx
  module Log
    class Entries
      include Loggable, Enumerable

      def initialize args = Hash.new
        @entries = Array.new

        if xmllines = args[:xmllines]
          # this is preferred

          doc = REXML::Document.new xmllines

          @logelements = doc.elements['log'].elements
          @size = @logelements.size
        elsif xmlentries = args[:xmlentries]
          # this is legacy:

          xmlentries.each do |xmlentry|
            @entries << Entry.new(:xmlentry => xmlentry)
          end
        end
      end

      def [] idx
        @entries[idx] ||= Entry.new(:xmlelement => @logelements[idx + 1])
      end

      def size
        @size
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

        @entries.each(&blk)
      end
    end
  end
end
