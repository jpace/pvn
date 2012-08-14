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
    class Format < ColorFormatter

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

      def initialize options
        @use_colors = options[:colors]
        # should also turn this off if not on a terminal that supports colors ...
      end

      def get_width field
        WIDTHS[field]
      end

      def get_colors field
        @use_colors ? COLORS[field] : nil
      end

      def format_summary entry, idx, total
        summary = add_field(entry.revision, :revision)
        negidx  = (-1 - idx).to_s
        summary << add_field(negidx, :neg_revision)

        if total
          posidx = "+#{total - idx - 1}"
        else
          summary << pad("", :pos_revision)
        end
        
        summary << add_field(entry.author, :author)        
        summary << colorize(entry.date, :date)
        summary
      end

      def format_message entry
        msg = entry.message
        @use_colors ? msg.white : msg
      end

      def format_paths entry
        lines = Array.new
        entry.paths.sort_by { |path| path.name }.each do |path|
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
      
      def format entry, idx, total
        if false
          info "entry.revision: #{entry.revision}"
          info "entry.author  : #{entry.author}"
          info "entry.date    : #{entry.date}"
          info "entry.message : #{entry.message}"
          entry.paths.each do |path|
            info "    path.kind  : #{path.kind}"
            info "    path.action: #{path.action}"
            info "    path.name  : #{path.name}"
          end
        end
        
        lines = Array.new
        
        lines << format_summary(entry, idx, total)
        lines << ""
        
        lines << format_message(entry)
        lines << ""

        lines.concat format_paths(entry)
        
        lines
      end
    end
  end
end
