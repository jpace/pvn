#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/config'

module PVN
  module Log
    class Entry
      include Loggable

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

      # WRITE_FORMAT_DEFAULT = '#{entry.revision}.yellow\n'
      WRITE_FORMAT_DEFAULT = '#{revision.yellow}\t#{user.green}\t#{date} #{time}\n#{list(comment)}#{cr(files)}#{list(files, :blue, :on_yellow)}\n'

      def set_from_args name, args
        self.instance_variable_set '@' + name.to_s, args[name]
      end

      # Reads a log entry from the text, starting at the first line at or after
      # lidx, matching the svn log separator line. Returns [ entry, new_index ],
      # where new_index is the updated index into the lines. Returns nil if the
      # text does not match the expected plain text format.
      def self.create_from_text lines, lidx = 0
        return TextOutputReader.create_from_text lines, lidx
      end

      def initialize args = Hash.new
        FIELDS.each do |field|
          set_from_args field, args
        end
      end

      def cr ary
        ary && !ary.empty? ? "\n" : ''
      end

      def list lines, *colors
        return '' unless lines
        
        lines.collect do |line|
          ln = line.chomp
          colors.each do |color|
            ln = ln.send(color)
          end
          "    " + ln + "\n"
        end.join('')
      end

      def write
        # ------------------------------------------------------------------------
        # r1907 | hielke.hoeve@gmail.com | 2011-11-14 05:50:38 -0500 (Mon, 14 Nov 2011) | 1 line
        #
        # back to dev

        cfg = PVN::Configuration.read
        
        logcfg = cfg.section "log"
        info "logcfg: #{logcfg}".on_red
        format = logcfg && logcfg.assoc('format') && logcfg.assoc('format')[1]
        info "format: #{format}".on_red

        format ||= WRITE_FORMAT_DEFAULT

        # @todo allow reformatting of date and time
        # format = WRITE_FORMAT_DEFAULT
        msg = eval('"' + format + '"')
        print msg
      end
    end
  end
end
