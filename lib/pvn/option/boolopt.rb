#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/option/option'

module PVN
  class BooleanOption < Option
    
    def takes_value?
      false
    end

    def to_command_line
      value && [ tag ]
    end
  end
end
