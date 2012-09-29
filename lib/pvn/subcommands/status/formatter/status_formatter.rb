#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/status/entry'
require 'pvn/util/color_formatter'

module PVN; module Status; end; end

module PVN::Status
  # a format for status entries
  class Formatter < PVN::ColorFormatter

    COLORS = {
      :added        => [ :green ],
      :modified     => [ :yellow ],
      :deleted      => [ :red ],
      :renamed      => [ :magenta ],
    }

    attr_reader :use_colors

    def initialize use_colors
      # should also turn this off if not on a terminal that supports colors ...
      @use_colors = use_colors
    end

    def colors field
      use_colors ? COLORS[field] : nil
    end
  end
end
