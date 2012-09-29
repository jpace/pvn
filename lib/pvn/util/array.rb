#!/usr/bin/ruby -w
# -*- ruby -*-

module PVN
  # a bad name, but I'm not sure if I'm going to monkey patch Array
  module ArrayUtil
    POS_NEG_NUMERIC_RE = Regexp.new('^[\-\+]?\d+$')

    # Returns the list joined by spaces, with each element in the list in double
    # quotes.
    def self.quote_list args
      args.collect { |a| "\"#{a}\"" }.join(' ') 
    end
  end
end
