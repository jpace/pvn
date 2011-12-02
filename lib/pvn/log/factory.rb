#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/log/entry'

module PVN
  module Log
    class TextFactory
      include Loggable

      LOG_RE = Regexp.new('^r(\d+) \| (\S+) \| (\S+) (\S+) (\S+) \((.*)\) \| (\d+) lines?$')
      LOG_SEPARATOR_RE = Regexp.new('^-{72}$')
      LOG_VERBOSE_START_RE = Regexp.new('^Changed paths:$')
      LOG_FILE_NAME_RE = Regexp.new('^   \w (.*)$')

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

      def match_line re, offset = 0
        re.match line(offset)
      end

      def match_log_start_line
        match_line(LOG_SEPARATOR_RE) && match_line(LOG_RE, 1)
      end

      def line offset = 0
        @lines[@lidx + offset]
      end

      def has_line
        @lidx < @lines.length
      end

      def advance_line offset = 1
        @lidx += offset
      end

      def read_comment
        comment = Array.new

        while has_line && !match_line(LOG_SEPARATOR_RE)
          comment << line.chomp
          debug "comment: #{comment}".cyan
          advance_line
        end

        comment
      end

      # Reads a log entry from the text, starting at the first line at or after
      # lidx, matching the svn log separator line. Returns [ entry, new_index ],
      # where new_index is the updated index into the lines. Returns nil if the
      # text does not match the expected plain text format.
      def create_next_entry
        while has_line
          if fielddata = match_log_start_line
            advance_line 2
            fields = Hash[Entry::FIELDS.zip(fielddata[1 .. -1])]
            
            if match_line(LOG_VERBOSE_START_RE)
              advance_line
              
              # files 

              fields[:files] = Array.new

              while (ln = line) && !ln.strip.empty?
                fname = match_line(LOG_FILE_NAME_RE)[1]

                info "fname: #{fname}".red

                fields[:files] << fname
                
                advance_line
              end
            end

            # skip the blank line
            advance_line

            debug "line: #{@lines[@lidx]}"

            fields[:comment] = read_comment
            
            debug "fields: #{fields}"

            return Entry.new(fields)
          end
          @lidx += 1
        end
        nil
      end
    end
  end
end
