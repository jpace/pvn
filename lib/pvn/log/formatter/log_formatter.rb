#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/entry'
require 'pvn/log/formatter/color_formatter'

module PVN; module Log; end; end

module PVN::Log
  # a format for log entries
  class Formatter < PVN::ColorFormatter

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
end
