#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/log/formatter/log_formatter'
require 'pvn/log/formatter/entry_formatter'

module PVN; module Log; end; end

module PVN::Log
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
