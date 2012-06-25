#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

module PVN
  # A filesystem element (directory or file).
  class FSElement < Pathname
    include Loggable
    attr_reader :name
    
    def initialize name
      @name = name
      super
    end
    
    def line_count
      readlines.size
    end
  end
end
