#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/subcommands/status/formatter/status_formatter'
require 'pvn/subcommands/status/formatter/entry_formatter'

module PVN; module Status; end; end

module PVN::Status
  class EntriesFormatter < Formatter
    def initialize use_color, entries
      super use_color
      @entries = entries
    end

    def format
      lines = Array.new
      total = @entries.size
      @entries.each_with_index do |entry, idx|
        ef = EntryFormatter.new use_colors, entry
        lines.concat ef.format
        # lines << '-' * 55
      end
      lines
    end
  end
end
