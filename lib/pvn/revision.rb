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
    
    # these are also valid revisions
    # :working_copy
    # :head

    include Loggable

    attr_reader :value
    attr_reader :log_entry

    class << self
      alias_method :orig_new, :new

      def new value, xmllines = nil
        # these are lines from "svn log -v <file>"
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
        when Symbol
          raise "symbol not yet handled"
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

    def to_s
      @value.to_s
    end
  end

  class FixnumRevision < Revision
  end

  class StringRevision < Revision
  end

  class WorkingCopyRevision < Revision
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

  # this is of the form: -r123:456
  class RevisionRange
    include Loggable
    
    attr_reader :from
    attr_reader :to

    def initialize from, to = nil, xmllines = nil
      if to
        @from = to_revision from, xmllines
        @to = to_revision to, xmllines
      else
        @from, @to = from.split(':').collect { |x| to_revision x, xmllines }
      end
    end

    def to_revision val, xmllines
      val.kind_of?(Revision) || Revision.new(val)
    end
    
    def to_s
      str = @from.to_s
      unless working_copy?
        str << ':' << @to.to_s
      end
      str
    end

    def head?
      @to == nil || @to == :head
    end

    def working_copy?
      @to == nil || @to == :wc || @to == :working_copy
    end
  end
end
