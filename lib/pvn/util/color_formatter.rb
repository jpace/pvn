#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'logue/loggable'
require 'rainbow'

module PVN
  class ColorFormatter
    include Logue::Loggable

    def pad what, field
      nspaces = [ width(field) - what.length, 1 ].max
      " " * nspaces
    end

    def colorize what, field
      colors = colors field
      return what if colors.nil? || colors.empty?
      colors.each do |col|
        case col
        when "bold", :bold
          what = what.bright
        else
          what = what.color col.to_sym
        end
      end
      what
    end

    def add_field value, field
      colorize(value, field) + pad(value, field)
    end
  end
end
