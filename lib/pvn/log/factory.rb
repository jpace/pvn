#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/log/entry'

module PVN
  module Log
    class TextFactory
      LOG_RE = Regexp.new('^r(\d+) \| (\S+) \| (\S+) (\S+) (\S+) \((.*)\) \| (\d+) lines?$')
      LOG_SEPARATOR_RE = Regexp.new('^-{72}$')
      LOG_VERBOSE_START_RE = Regexp.new('^Changed paths:$')

      def initialize lines
        @lines = lines
        @lidx = 0
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

      def match_log_start_line
        LOG_SEPARATOR_RE.match(@lines[@lidx]) && LOG_RE.match(@lines[@lidx + 1])
      end

      def read_comment
        comment = Array.new

        while @lidx < @lines.length && !LOG_SEPARATOR_RE.match(@lines[@lidx])
          RIEL::Log.debug "lines[#{@lidx}]: #{@lines[@lidx]}".cyan
          comment << @lines[@lidx].chomp
          RIEL::Log.debug "comment: #{comment}".cyan
          @lidx += 1
        end

        comment
      end

      # Reads a log entry from the text, starting at the first line at or after
      # lidx, matching the svn log separator line. Returns [ entry, new_index ],
      # where new_index is the updated index into the lines. Returns nil if the
      # text does not match the expected plain text format.
      def create_next_entry
        while @lidx < @lines.length
          if fielddata = match_log_start_line
            @lidx += 2
            fields = Hash[Entry::FIELDS.zip(fielddata[1 .. -1])]
            
            if LOG_VERBOSE_START_RE.match @lines[@lidx]
              # todo: handle files
              return -1
            end

            # skip the blank line
            @lidx += 1

            RIEL::Log.debug "line: #{@lines[@lidx]}"

            fields[:comment] = read_comment
            
            RIEL::Log.debug "fields: #{fields}"

            return Entry.new(fields)
          end
          @lidx += 1
        end
        nil
      end
    end
  end
end