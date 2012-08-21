#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/entries'

module PVN::Revisionxxx
  DATE_REGEXP = Regexp.new '^\{(.*?)\}'
  SVN_REVISION_WORDS = %w{ HEAD BASE COMMITTED PREV }
  RELATIVE_REVISION_RE = Regexp.new '^([\+\-])(\d+)$'

  # Returns the Nth revision from the given logging output.

  # -n means to count from the end of the list.
  # +n means to count from the beginning of the list.
  #  n means the literal revision number.  
  class Entry
    include Loggable

    attr_reader :value
    attr_reader :log_entry

    class << self
      alias_method :orig_new, :new

      def new args = Hash.new
        value = args[:value]

        Log.info "value: #{value}"

        # these are lines from "svn log -v <file>"
        xmllines = args[:xmllines]
        if xmllines.kind_of? Array
          xmllines = xmllines.join ''
        end

        case value
        when Fixnum
          if value < 0
            RelativeEntry.orig_new value, xmllines
          else
            FixnumEntry.orig_new value
          end
        when String
          if SVN_REVISION_WORDS.include? value
            StringEntry.orig_new value
          elsif md = RELATIVE_REVISION_RE.match(value)
            RelativeEntry.orig_new md[0].to_i, xmllines
          elsif DATE_REGEXP.match value
            StringEntry.orig_new value
          else
            FixnumEntry.orig_new value.to_i
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

  class FixnumEntry < Entry
  end

  class StringEntry < Entry
  end

  class RelativeEntry < FixnumEntry
    def initialize value, xmllines
      raise "cannot determine relative revision without xmllines" unless xmllines

      logentries = SVNx::Log::Entries.new :xmllines => xmllines

      # logentries are in descending order, so the most recent one is index 0
      info "logentries: #{logentries.size}"

      if value.abs > logentries.size
        super nil
      else
        idx = value < 0 ? -1 + value.abs : logentries.size - value
        @log_entry = logentries[idx]
        super @log_entry.revision.to_i
      end
    end
  end
end
