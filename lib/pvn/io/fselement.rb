#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/linecount'
require 'pvn/io'
require 'pvn/util'

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
      IO::numlines(self)
    end
  end
end
