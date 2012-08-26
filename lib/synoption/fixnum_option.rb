#!/usr/bin/ruby -w
# -*- ruby -*-

require 'synoption/option'

module PVN
  # An option that has a fixnum (integer) as its value.
  class FixnumOption < Option
    def set_value val
      super val.to_i
    end
  end
end
