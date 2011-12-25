#!/usr/bin/ruby -w
# -*- ruby -*-

module PVN
  module Util
    POS_NEG_NUMERIC_RE = Regexp.new('^([\-\+])?(\d+)$')

    # returns the value as an integer, if it is not negative
    def self.negative_integer? val
      negnumre = Regexp.new '^(\-\d+)$'
      
      if val.nil?
        nil
      elsif val.kind_of? Integer
        val < 0 && val
      elsif md = negnumre.match(val.to_s)
        md[1].to_i
      else
        nil
      end
    end
    
    # Returns the list joined by spaces, with each element in the list in double
    # quotes.
    def self.quote_list args
      args.collect { |a| "\"#{a}\"" }.join(' ') 
    end
  end
end
