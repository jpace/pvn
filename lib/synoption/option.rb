#!/usr/bin/ruby -w
# -*- ruby -*-

require 'synoption/base_option'
require 'riel/log/loggable'

module PVN
  class Option < BaseOption
    include RIEL::Loggable
  end
end
