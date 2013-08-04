#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/entries'
require 'pvn/revision/argument'
require 'logue/loggable'

module PVN; module Revision; end; end

module PVN::Revision
  # this is of the form: -r123:456
  class Range
    include Logue::Loggable
    
    attr_reader :from
    attr_reader :to

    def initialize from, to = nil, xmllines = nil
      if to
        @from = to_revision from, xmllines
        @to = to_revision to, xmllines
      elsif from.kind_of? String
        @from, @to = from.split(':').collect { |x| to_revision x, xmllines }
      else
        @from = to_revision from, xmllines
        @to = :working_copy
      end
    end

    def to_revision val, xmllines
      val.kind_of?(Argument) || Argument.new(val, xmllines)
    end
    
    def to_s
      str = @from.to_s
      unless working_copy?
        str << ':' << @to.to_s
      end
      str
    end

    def head?
      @to == :head
    end

    def working_copy?
      @to == nil || @to == :wc || @to == :working_copy
    end
  end
end
