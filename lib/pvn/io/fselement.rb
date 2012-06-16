#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/base/io'

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
      IO::numlines self
    end
  end
end
