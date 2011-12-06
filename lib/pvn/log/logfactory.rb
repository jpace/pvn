#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/log/logentry'
require 'pvn/textlines'

module PVN
  module Log
    SVN_LOG_SUMMARY_LINE_RE = Regexp.new('^r(\d+) \| (\S+) \| (\S+) (\S+) (\S+) \((.*)\) \| (\d+) lines?$')
    SVN_LOG_SEPARATOR_LINE_RE = Regexp.new('^-{72}$')
    SVN_LOG_VERBOSE_START_RE = Regexp.new('^Changed paths:$')
    SVN_LOG_FILE_NAME_RE = Regexp.new('^   \w (.*)$')

    class TextFactory
      include Loggable

      def initialize lines
        @textlines = TextLines.new lines
        @entries = nil
      end

      def entries
        @entries ||= begin
                       entries = Array.new
                       while entry = create_next_entry
                         entries << entry
                       end
                       entries
                     end
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
          # debug "comment: #{comment}"
          advance_line
        end

        comment
      end

      # Reads a log entry from the text, starting at the first line at or after
      # lidx, matching the svn log separator line. Returns [ entry, new_index ],
      # where new_index is the updated index into the lines. Returns nil if the
      # text does not match the expected plain text format.
      def create_next_entry
        while has_line?
          if fielddata = match_log_start_line
            advance_line 2
            fields = Hash[Entry::FIELDS.zip(fielddata[1 .. -1])]
            
            if match_line SVN_LOG_VERBOSE_START_RE
              advance_line
              
              # files 

              fields[:files] = Array.new

              while (ln = current_line) && !ln.strip.empty?
                fname = match_line(SVN_LOG_FILE_NAME_RE)[1]

                info "fname: #{fname}".red

                fields[:files] << fname
                
                advance_line
              end
            end

            # skip the blank line
            advance_line

            # debug "line: #{current_lines[@lidx]}"

            fields[:comment] = read_comment
            
            debug "fields: #{fields}"

            return Entry.new(fields)
          end
          advance_line
        end
        nil
      end
    end
  end
end
