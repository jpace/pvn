#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/revision/entry'

module PVN
  # Returns the Nth revision from the given logging output.

  # -n means to count from the end of the list.
  # +n means to count from the beginning of the list.
  #  n means the literal revision number.  
  module Revisionxxx
    DATE_REGEXP = Regexp.new('^\{(.*?)\}')
    SVN_REVISION_WORDS = %w{ HEAD BASE COMMITTED PREV }

    class Argument
      include Loggable

      NEGATIVE_NUM_RE = Regexp.new '\-(\d+)$'
      POSITIVE_NUM_RE = Regexp.new '\+(\d+)$'
      
      attr_reader :value

      def initialize val
        info "val: #{val}"
        info "val.class: #{val.class}"

        @positive = false
        @negative = false

        case val
        when Fixnum
          info "fixnum: #{val}"
          @value = val.abs.to_i
          @negative = val < 0
        when String
          info "string: #{val}".cyan
          if SVN_REVISION_WORDS.include? val
            @value = val.to_s
          elsif md = NEGATIVE_NUM_RE.match(val)
            @value = md[1].to_i
            @negative = true
          elsif md = POSITIVE_NUM_RE.match(val)
            @value = md[1].to_i
            @positive = true
          else
            @value = val.to_i
          end
        when Date
          # $$$ this (and Time) will probably have to be converted to svn's format
          raise "date not yet handled"
        when Time
          raise "time not yet handled"
        end
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
  end
end
