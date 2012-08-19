#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/entry'

module PVN
  class ColorFormatter
    include Loggable

    def pad what, field
      nspaces = [ width(field) - what.length, 1 ].max
      " " * nspaces
    end

    def colorize what, field
      colors = colors field
      return what if colors.nil? || colors.empty?
      colors.each do |col|
        what = what.send col
      end
      what
    end

    def add_field value, field
      colorize(value, field) + pad(value, field)
    end
  end

  module Log
    # a format for log entries
    class Formatter < ColorFormatter

      WIDTHS = { 
        :revision     => 10, 
        :neg_revision => 5,
        :pos_revision => 5,
        :author       => 25
      }

      COLORS = {
        :revision     => [ :bold ],
        :neg_revision => [ :bold ],
        :pos_revision => [ :bold ],
        :author       => [ :bold, :cyan ],
        :date         => [ :bold, :magenta ],

        :added        => [ :green ],
        :modified     => [ :yellow ],
        :deleted      => [ :red ],
        :renamed      => [ :magenta ],

        :dir          => [ :bold ],
      }

      attr_reader :use_colors

      def initialize use_colors
        @use_colors = use_colors
        # should also turn this off if not on a terminal that supports colors ...
      end

      def write_entries entries, out = $stdout
        entries.each_with_index do |entry, idx|
          fmtlines = format entry, idx, entries.size
          
          out.puts fmtlines
          out.puts '-' * 55
        end
      end

      def width field
        WIDTHS[field]
      end

      def colors field
        use_colors ? COLORS[field] : nil
      end

      def format_entry entry, idx, total
        ef = EntryFormatter.new use_colors, entry, idx, false, false, total
        ef.format
      end
    end

    class SummaryFormatter < Formatter
      attr_reader :entry
      attr_reader :idx
      attr_reader :from_head
      attr_reader :from_tail
      attr_reader :total

      def initialize use_colors, entry, idx, from_head, from_tail, total
        super use_colors
        @entry = entry
        @idx = idx
        @from_head = from_head
        @from_tail = from_tail
        @total = total
      end

      def format
        lines = add_field(entry.revision, :revision)
        negidx  = (-1 - idx).to_s

        if from_head
          lines << add_field(negidx, :neg_revision)
        else
          lines << pad("", :neg_revision)
        end

        # info "@total: #{total}".on_blue

        if from_tail
          posidx = "+#{total - idx - 1}"
          lines << add_field(posidx, :pos_revision)
        else
          lines << pad("", :pos_revision)
        end
        
        lines << add_field(entry.author, :author)
        lines << colorize(entry.date, :date)
        lines
      end
    end
    
    class MessageFormatter < Formatter
      def initialize use_colors, msg
        super use_colors
        @msg = msg
      end

      def format
        use_colors ? @msg.white : @msg
      end
    end

    class PathFormatter < Formatter
      PATH_ACTIONS = {
        'M' => :modified,
        'A' => :added,
        'D' => :deleted,
        'R' => :renamed
      }

      def initialize use_colors, paths
        super use_colors
        @paths = paths
      end

      def format
        lines = Array.new
        @paths.sort_by { |path| path.name }.each do |path|
          pstr = "    "
          if field = PATH_ACTIONS[path.action]
            pstr << colorize(path.name, field)
          else
            raise "wtf?: #{path.action}"
          end

          if path.kind == 'dir'
            pstr = colorize(pstr, :dir)
          end

          lines << pstr
        end
        lines
      end
    end

    class EntryFormatter < Formatter
      attr_reader :entry
      attr_reader :idx
      attr_reader :from_head
      attr_reader :from_tail
      attr_reader :total

      def initialize use_colors, entry, idx, from_head, from_tail, total
        super use_colors
        @entry = entry
        @idx = idx
        @from_head = from_head
        @from_tail = from_tail
        @total = total
      end
      
      def format
        if false
          info "@entry.revision: #{@entry.revision}"
          info "@entry.author  : #{@entry.author}"
          info "@entry.date    : #{@entry.date}"
          info "@entry.message : #{@entry.message}"
          @entry.paths.each do |path|
            info "    path.kind  : #{path.kind}"
            info "    path.action: #{path.action}"
            info "    path.name  : #{path.name}"
          end
        end
        
        lines = Array.new
        
        sf = SummaryFormatter.new use_colors, entry, idx, from_head, from_tail, total
        lines << sf.format
        lines << ""
        
        mf = MessageFormatter.new use_colors, entry.message
        lines << mf.format
        lines << ""

        pf = PathFormatter.new use_colors, entry.paths
        lines.concat pf.format
        
        lines
      end
    end

    class EntriesFormatter < Formatter
      attr_reader :from_head
      attr_reader :from_tail

      def initialize use_color, entries, from_head, from_tail
        super use_color
        @entries = entries
        @from_head = from_head
        @from_tail = from_tail
      end

      def format
        lines = Array.new
        total = @entries.size
        @entries.each_with_index do |entry, idx|
          ef = EntryFormatter.new use_colors, entry, idx, from_head, from_tail, total
          lines.concat ef.format
        
          lines << '-' * 55
        end
        lines
      end
    end
  end
end
