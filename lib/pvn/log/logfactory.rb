#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/log/logentry'
require 'pvn/base/textlines'

module PVN
  module Log
    SVN_LOG_SUMMARY_LINE_RE = Regexp.new('^r(\d+) \| (\S+) \| (\S+) (\S+) (\S+) \((.*)\) \| (\d+) lines?$')
    SVN_LOG_SEPARATOR_LINE_RE = Regexp.new('^-{72}$')
    SVN_LOG_VERBOSE_START_RE = Regexp.new('^Changed paths:$')
    SVN_LOG_FILE_NAME_RE = Regexp.new('^   (\w) (.*)$')

    class TextFactory
      include Loggable

      def initialize lines
        @textlines = TextLines.new lines
        @entries = nil
      end

      def entries
        @entries ||= read_entries
      end

      def read_entries
        entries = Array.new
        while entry = create_next_entry
          entries << entry
        end
        entries
      end

      def match_line re, offset = 0
        @textlines.match_line re, offset
      end

      def advance_line nlines = 1
        @textlines.advance_line nlines
      end

      def match_log_start_line
        match_line(SVN_LOG_SEPARATOR_LINE_RE) && match_line(SVN_LOG_SUMMARY_LINE_RE, 1)
      end

      def has_line?
        @textlines.has_line?
      end

      def current_line
        @textlines.line
      end

      def read_comment
        comment = Array.new
        while has_line? && !match_line(SVN_LOG_SEPARATOR_LINE_RE)
          comment << current_line.chomp
          advance_line
        end
        comment
      end

      def read_files
        advance_line
        files = Array.new
        while (ln = current_line) && !ln.strip.empty?
          md = match_line(SVN_LOG_FILE_NAME_RE)
          changetype = md[1]
          fname = md[2]
          files << fname
          advance_line
        end        
        files
      end

      def create_entry fielddata
        advance_line 2
        fields = Hash[Entry::FIELDS.zip fielddata[1 .. -1]]
        if match_line SVN_LOG_VERBOSE_START_RE
          fields[:files] = read_files
        end
        advance_line
        fields[:comment] = read_comment
        return Entry.new fields
      end

      def create_next_entry
        while has_line?
          if fielddata = match_log_start_line
            return create_entry fielddata
          else
            advance_line
          end
        end
        nil
      end
    end
  end
end
