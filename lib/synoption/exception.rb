#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel/log/loggable'

module PVN
  class OptionException < RuntimeError
    include RIEL::Loggable
  end
end
