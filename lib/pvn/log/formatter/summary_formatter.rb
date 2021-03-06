#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/log/formatter/log_formatter'
require 'pvn/log/formatter/date_formatter'
require 'date'

module PVN; module Log; end; end

module PVN::Log
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
      lines = add_field entry.revision, :revision
      negidx  = (-1 - idx).to_s

      if from_head
        lines << add_field(negidx, :neg_revision)
      else
        lines << pad("", :neg_revision)
      end

      if from_tail
        posidx = "+#{total - idx - 1}"
        lines << add_field(posidx, :pos_revision)
      else
        lines << pad("", :pos_revision)
      end
      
      lines << add_field(entry.author, :author)
      info "entry.date: #{entry.date}"
      info "entry.date.class: #{entry.date.class}"
      dt = DateTime.parse entry.date
      info "dt: #{dt}"
      dfmt = DateFormatter.new.format(entry.date)
      lines << colorize(dfmt, :date)
      lines
    end
  end
end
