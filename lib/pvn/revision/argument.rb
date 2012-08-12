#!/usr/bin/ruby -w
# -*- ruby -*-

# require 'pvn/revision/entry'

module PVN
  # Returns the Nth revision from the given logging output.

  # -n means to count from the end of the list.
  # +n means to count from the beginning of the list.
  #  n means the literal revision number.  
  module Revisionxxx
    DATE_REGEXP = Regexp.new('^\{(.*?)\}')
    SVN_REVISION_WORDS = %w{ HEAD BASE COMMITTED PREV }
    RELATIVE_REVISION_RE = Regexp.new '([\+\-])(\d+)$'

    class Argument
      include Loggable

      class << self
        alias_method :orig_new, :new

        def new val
          case val
          when Fixnum
            ::RIEL::Log.info "fixnum: #{val}"
            if val < 0
              return RelativeArgument.orig_new val, true
            else
              return FixnumArgument.orig_new val
            end
          when String
            ::RIEL::Log.info "string: #{val}".cyan
            if SVN_REVISION_WORDS.include? val
              return Argument.orig_new val.to_s
            elsif md = RELATIVE_REVISION_RE.match(val)
              return RelativeArgument.orig_new md[2].to_i, md[1] == '-'
            else
              return Argument.orig_new val.to_i
            end
          when Date
            # $$$ this (and Time) will probably have to be converted to svn's format
            raise "date not yet handled"
          when Time
            raise "time not yet handled"
          end
        end
      end
      
      attr_reader :value

      def initialize val
        info "val: #{val}"
        info "val.class: #{val.class}"

        @positive = @negative = false
        @value = val
      end

      # the value is of the form "-N" or "+N"
      def relative?
        @negative || @positive
      end

      # the value is of the form "-N"
      def negative?
        @negative
      end

      # positive means the value is of the form "+N", not simply N > 0
      def positive?
        @positive
      end
    end

    class FixnumArgument < Argument
      def initialize val
        super
      end
    end

    class RelativeArgument < Argument
      def initialize val, is_negative
        super val.abs
        @negative = is_negative
        @positive = !is_negative
      end
    end
  end
end
