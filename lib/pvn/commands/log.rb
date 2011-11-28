#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/commands/cachecmd'

module PVN
  module Logx
    class Entry
      FIELDS = [ :revision,
                 :user,
                 :date,
                 :time,
                 :tz,
                 :dtg,
                 :nlines,
                 :files,
                 :comment ]

      FIELDS.each do |field|
        attr_reader field
      end

      def set_from_args name, args
        self.instance_variable_set '@' + name.to_s, args[name]
      end

      LOG_RE = Regexp.new('^r(\d+) \| (\S+) \| (\S+) (\S+) (\S+) \((.*)\) \| (\d+) lines?$')
      LOG_SEPARATOR_RE = Regexp.new('^-{72}$')
      LOG_VERBOSE_START_RE = Regexp.new('^Changed paths:$')

      def self.match_log_start_line lines, lidx
        LOG_SEPARATOR_RE.match(lines[lidx]) && LOG_RE.match(lines[lidx + 1])
      end

      def self.read_comment lines, lidx
        comment = Array.new

        while lidx < lines.length && !LOG_SEPARATOR_RE.match(lines[lidx])
          Log.info "lines[#{lidx}]: #{lines[lidx]}".cyan
          comment << lines[lidx].chomp
          Log.info "comment: #{comment}".cyan
          lidx += 1
        end

        comment
      end

      # Reads a log entry from the text, starting at the first line at or after
      # lidx, matching the svn log separator line. Returns [ entry, new_index ],
      # where new_index is the updated index into the lines. Returns nil if the
      # text does not match the expected plain text format.
      def self.create_from_text lines, lidx = 0
        while lidx < lines.length
          if fielddata = match_log_start_line(lines, lidx)
            lidx += 2
            fields = Hash[FIELDS.zip(fielddata[1 .. -1])]
            
            if LOG_VERBOSE_START_RE.match(lines[lidx])
              # todo
              return -1
            end

            # skip the blank line
            lidx += 1

            Log.info "line: #{lines[lidx]}".yellow

            fields[:comment] = read_comment(lines, lidx)
            
            Log.info "fields: #{fields}"

            return [ Entry.new(fields), lidx ]
          end
          lidx += 1
        end
        nil
      end

      def initialize args = Hash.new
        FIELDS.each do |field|
          set_from_args field, args
        end
      end
    end

    class Command < CachableCommand
      def initialize args
        command = %w{ svn log }

        # todo: handle revision conversion:
        fromrev = args[:fromrev]
        torev   = args[:torev]

        if fromrev && torev
          command << "-r" << "#{fromrev}:#{torev}"
        elsif args[:fromdate] && args[:todate]
          command << "-r" << "\{#{fromdate}\}:\{#{todate}\}"
        end
        info "command: #{command}".on_red
      end
    end
  end
end