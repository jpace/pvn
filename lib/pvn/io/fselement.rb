#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel/pathname'
require 'logue/loggable'

module PVN
  # A filesystem element (directory or file).
  class FSElement < Pathname
    include Logue::Loggable
    
    attr_reader :name
    
    def initialize name
      @name = name
      super
    end
    
    def line_count
      readlines.size
    end

    def to_s
      super
    end
  end
end
