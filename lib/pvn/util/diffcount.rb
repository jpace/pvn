#!/usr/bin/ruby -w
# -*- ruby -*-

module PVN
  class DiffCount
    attr_reader :from
    attr_reader :to
    attr_reader :name

    def initialize from = 0, to = 0, name = nil
      @from = from
      @to = to
      @name = name
    end

    def print name = @name
      diff = to - from
      diffpct = diff == 0 ? 0 : 100.0 * diff / from
      
      $io.printf "%8d %8d %8d %8.1f%% %s\n", from, to, diff, diffpct, name
    end

    def << diff
      @from += diff.from
      @to += diff.to
    end
  end
end
