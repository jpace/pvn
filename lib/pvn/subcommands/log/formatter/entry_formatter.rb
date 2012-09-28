#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/subcommands/log/formatter/log_formatter'
require 'pvn/subcommands/log/formatter/summary_formatter'
require 'pvn/subcommands/log/formatter/message_formatter'
require 'pvn/subcommands/log/formatter/path_formatter'

module PVN; module Log; end; end

module PVN::Log
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
end
