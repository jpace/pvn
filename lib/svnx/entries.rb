#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rexml/document'

module SVNx
  # this is a parse/process on-demand list of entries, acting like an
  # Enumerable.

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

        @elements = get_elements doc
        @size = @elements.size
      elsif xmlentries = args[:xmlentries]
        raise "argument xmlentries is no longer supported"
      end
    end

    def get_elements doc
    end

    def create_entry xmlelement
    end

    def [] idx
      @entries[idx] ||= create_entry(@elements[idx + 1])
    end

    def each(&blk)
      # all elements must be processed before this can happen:
      if @elements
        # a little confusing here: REXML does each_with_index with idx
        # zero-based, but elements[0] is invalid.
        @elements.each_with_index do |element, idx|
          @entries[idx] ||= create_entry(element)
        end

        @elements = nil
      end

      @entries.keys.sort.collect { |idx| @entries[idx] }.each(&blk)
    end
  end
end