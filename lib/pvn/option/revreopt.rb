#!/usr/bin/ruby -w
# -*- ruby -*-

require 'riel'
require 'rubygems'
require 'pvn/option/revopt'

module PVN
  # A revision that is also set by -N and +N.
  class RevisionRegexpOption < RevisionOption
    attr_accessor :fromdate
    attr_accessor :todate

    POS_NEG_NUMERIC_RE = Regexp.new('^[\-\+]?\d+$')

    REVISION_DESCRIPTION = [ "revision to apply.",
                             "ARG can be relative, of the form:",
                             "    +N : N revisions from the BASE",
                             "    -N : N revisions from the HEAD,",
                             "         when -1 is the previous revision" ,
                           ]
    
    def initialize revargs = Hash.new
      revargs[:regexp] = POS_NEG_NUMERIC_RE
      super
    end    
  end
end
