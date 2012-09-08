#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/status/formatter/status_formatter'

module PVN; module Status; end; end

module PVN::Status
  class EntryFormatter < Formatter
    attr_reader :entry

    def initialize use_colors, entry
      super use_colors
      @entry = entry
    end
    
    def format
      lines = Array.new

      lines << entry.inspect
      
      lines
    end
  end
end
