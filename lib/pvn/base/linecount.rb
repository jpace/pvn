#!/usr/bin/ruby -w
# -*- ruby -*-

module PVN
  class LineCount
    attr_accessor :to
    attr_accessor :from
    attr_accessor :name

    def initialize args = Hash.new
      @name = args[:name] || ""
      @to   = args[:to]   || 0
      @from = args[:from] || 0
    end

    def +(other)
      # the new wc has the name of the lhs of the add:
      self.class.new :to => @to + other.to, :from => @from + other.from, :name => @name
    end

    def diff
      @to - @from
    end

    def diffpct
      @from.zero? ? "0" : 100.0 * diff / @from
    end

    def write
      printf "%8d %8d %8d %8.1f%% %s\n", @from, @to, diff, diffpct, @name
    end
  end
end
