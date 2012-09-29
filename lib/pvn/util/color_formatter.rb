#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel/log'

module PVN
  class ColorFormatter
    include Loggable

    def pad what, field
      nspaces = [ width(field) - what.length, 1 ].max
      " " * nspaces
    end

    def colorize what, field
      colors = colors field
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
end
