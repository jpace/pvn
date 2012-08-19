#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/entry'

module PVN
  class ColorFormatter
    include Loggable

    def pad what, field
      nspaces = [ get_width(field) - what.length, 1 ].max
      " " * nspaces
    end

    def colorize what, field
      colors = get_colors field
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

      PATH_ACTIONS = {
        'M' => :modified,
        'A' => :added,
        'D' => :deleted,
        'R' => :renamed
      }

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

      def get_width field
        WIDTHS[field]
      end

      def get_colors field
        @use_colors ? COLORS[field] : nil
      end

      def format_entry entry, idx, total
        ef = EntryFormatter.new @use_colors, entry, idx, total
        ef.format
      end
    end

    class SummaryFormatter < Formatter
      def initialize use_colors, entry, idx, total
        super use_colors
        @entry = entry
        @idx = idx
        @total = total
      end

      def format
        lines = add_field(@entry.revision, :revision)
        negidx  = (-1 - @idx).to_s
        lines << add_field(negidx, :neg_revision)

        info "@total: #{@total}".on_blue

        if @total
          posidx = "+#{@total - @idx - 1}"
        else
          lines << pad("", :pos_revision)
        end
        
        lines << add_field(@entry.author, :author)
        lines << colorize(@entry.date, :date)
        lines
      end
    end
    
    class MessageFormatter < Formatter
      def initialize use_colors, msg
        super use_colors
        @msg = msg
      end

      def format
        @use_colors ? @msg.white : @msg
      end
    end

    class PathFormatter < Formatter
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
      def initialize use_colors, entry, idx, total
        super use_colors
        @entry = entry
        @idx = idx
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
        
        sf = SummaryFormatter.new @use_colors, @entry, @idx, @total
        lines << sf.format
        lines << ""
        
        mf = MessageFormatter.new @use_colors, @entry.message
        lines << mf.format
        lines << ""

        pf = PathFormatter.new(@use_colors, @entry.paths)
        lines.concat pf.format
        
        lines
      end
    end
  end
end
