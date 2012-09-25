#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/entries'

# This is an abuse of all the element/entry nonsense in this code. This will
# replace lib/pvn/revision.rb as PVN::Revision.                                                                            

module PVN
  class RevisionError < RuntimeError
  end

  # Returns the Nth revision from the given logging output.

  # -n means to count from the end of the list.
  # +n means to count from the beginning of the list.
  #  n means the literal revision number.  
  class Revision
    DATE_REGEXP = Regexp.new '^\{(.*?)\}'
    SVN_REVISION_WORDS = %w{ HEAD BASE COMMITTED PREV }
    RELATIVE_REVISION_RE = Regexp.new '^([\+\-])(\d+)$'

    include Loggable

    attr_reader :value
    attr_reader :log_entry

    class << self
      alias_method :orig_new, :new

      def new args = Hash.new
        value = args[:value]

        # these are lines from "svn log -v <file>"
        xmllines = args[:xmllines]
        if xmllines.kind_of? Array
          xmllines = xmllines.join ''
        end

        case value
        when Fixnum
          if value < 0
            RelativeRevision.orig_new value, xmllines
          else
            FixnumRevision.orig_new value
          end
        when String
          if SVN_REVISION_WORDS.include? value
            StringRevision.orig_new value
          elsif md = RELATIVE_REVISION_RE.match(value)
            RelativeRevision.orig_new md[0].to_i, xmllines
          elsif DATE_REGEXP.match value
            StringRevision.orig_new value
          else
            FixnumRevision.orig_new value.to_i
          end
        when Date
          # $$$ this (and Time) will probably have to be converted to svn's format
          raise "date not yet handled"
        when Time
          raise "time not yet handled"
        end          
      end

      def matches_relative? str
        RELATIVE_REVISION_RE.match str
      end
    end

    def initialize value
      @value = value
    end
  end

  class FixnumRevision < Revision
  end

  class StringRevision < Revision
  end

  class RelativeRevision < FixnumRevision
    def initialize value, xmllines
      unless xmllines
        raise RevisionError.new "cannot determine relative revision without xmllines"
      end
      
      logentries = SVNx::Log::Entries.new :xmllines => xmllines
      nentries = logentries.size

      # logentries are in descending order, so the most recent one is index 0

      if value.abs > nentries
        raise RevisionError.new "ERROR: no entry for revision: #{value.abs}; number of entries: #{nentries}"
      else
        idx = value < 0 ? -1 + value.abs : nentries - value
        @log_entry = logentries[idx]
        super @log_entry.revision.to_i
      end
    end
  end
end
