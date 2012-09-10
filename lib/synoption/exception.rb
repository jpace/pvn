#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

module PVN
  class OptionException < RuntimeError
    include Loggable

  end
end
