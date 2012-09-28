#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/subcommands/log/formatter/log_formatter'

module PVN; module Log; end; end

module PVN::Log
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
end
