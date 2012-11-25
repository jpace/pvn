#!/usr/bin/ruby -w
# -*- ruby -*-

require 'synoption/boolean_option'

module PVN::Command
  class ColorOption < PVN::BooleanOption
    def initialize optargs = Hash.new
      super :color, nil, "show colorized output", true, :negate => [ '-C', %r{^--no-?color} ], :as_cmdline_option => nil
    end
  end
end
