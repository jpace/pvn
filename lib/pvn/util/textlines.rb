#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel/log/loggable'

module PVN
  class TextLines
    include RIEL::Loggable

    attr_reader :lines

    def initialize lines
      @lines = lines
      @lidx = 0
    end

    def match_line re, offset = 0
      re.match line(offset)
    end

    def line offset = 0
      @lines[@lidx + offset]
    end

    def has_line?
      @lidx < @lines.length
    end

    def advance_line offset = 1
      @lidx += offset
    end
    
  end
end
