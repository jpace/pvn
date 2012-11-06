#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/command/options'
require 'pvn/command/color_option'

module PVN::Status
  class OptionSet < PVN::Command::OptionSet
    has_option :color, PVN::Command::ColorOption
  end
end
