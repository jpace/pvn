#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel/log/loggable'
require 'synoption/match'

module PVN
  class Matchers
    include RIEL::Loggable

    attr_reader :exact
    attr_reader :negative
    attr_reader :regexp

    def initialize tag, name, negate, regexp
      @exact = OptionExactMatch.new tag, name
      @negative = negate && OptionNegativeMatch.new(negate)
      @regexp = regexp && OptionRegexpMatch.new(regexp)
    end
  end
end
