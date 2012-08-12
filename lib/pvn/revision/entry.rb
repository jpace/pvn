#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/log/logcmd'
require 'svnx/log/entries'
require 'pvn/revision/argument'

module PVN
  # Returns the Nth revision from the given logging output.

  # -n means to count from the end of the list.
  # +n means to count from the beginning of the list.
  #  n means the literal revision number.  
  module Revisionxxx
    DATE_REGEXP = Regexp.new('^\{(.*?)\}')
    SVN_REVISION_WORDS = %w{ HEAD BASE COMMITTED PREV }
    RELATIVE_REVISION_RE = Regexp.new '([\+\-])(\d+)$'

    class Entry
      include Loggable

      attr_reader :value
      attr_reader :log_entry

      class << self
        alias_method :orig_new, :new

        def new args = Hash.new
          value = args[:value]
          xmllines = args[:xmllines]
          arg = nil

          val = args[:value]
          arg = case val
                when Fixnum
                  ::RIEL::Log.info "fixnum: #{val}"
                  if val < 0
                    # RelativeArgument.orig_new val, true
                    return RelativeEntry.orig_new val, true, xmllines
                  else
                    args[:value] = val
                    return FixnumEntry.orig_new val
                  end
                when String
                  ::RIEL::Log.info "string: #{val}".cyan
                  if SVN_REVISION_WORDS.include? val
                    return StringEntry.orig_new val
                  elsif md = RELATIVE_REVISION_RE.match(val)
                    RelativeArgument.orig_new md[2].to_i, md[1] == '-'
                  else
                    args[:value] = val.to_i
                    return FixnumEntry.orig_new val.to_i
                  end
                when Date
                  # $$$ this (and Time) will probably have to be converted to svn's format
                  raise "date not yet handled"
                when Time
                  raise "time not yet handled"
                end
          
          ::RIEL::Log.info "arg: #{arg}".red

          args[:arg] = arg

          orig_new args
        end
      end

      def initialize args = Hash.new
        # info "args: #{args}".yellow
        info "args[:value]: #{args[:value]}".yellow
        info "args[:arg]: #{args[:arg]}".yellow

        if arg = args[:arg]
          if arg.relative?
            set_as_relative arg, args[:xmllines]
          else
            @value = arg.value
          end
        else
          @value = args[:value]
        end
      end

      def set_as_relative arg, xmllines
        raise "cannot determine relative revision without xmllines" unless xmllines

        logentries = SVNx::Log::Entries.new :xmllines => xmllines

        # logentries are in descending order, so the most recent one is index 0
        info "logentries: #{logentries.size}".red

        val = arg.value

        if val > logentries.size
          @value = nil
        else
          idx = arg.negative? ? -1 + val : logentries.size - val
          @log_entry = logentries[idx]
          @value = @log_entry.revision.to_i
        end
      end
    end
    
    class FixnumEntry < Entry
      def initialize value
        args = Hash.new
        args[:value] = value
        super args
      end
    end

    class StringEntry < Entry
      def initialize value
        args = Hash.new
        args[:value] = value
        super args
      end
    end

    class RelativeEntry < FixnumEntry
      def initialize value, is_negative, xmllines
        args = Hash.new
        args[:value] = value
        args[:arg] = RelativeArgument.orig_new value, is_negative
        args[:xmllines] = xmllines
        super args
        # @negative = is_negative
        # @positive = !is_negative
      end
    end
  end
end
