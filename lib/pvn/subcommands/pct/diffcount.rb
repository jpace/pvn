#!/usr/bin/ruby -w
# -*- ruby -*-

module PVN
  class DiffCount
    attr_reader :from
    attr_reader :to

    def initialize from = 0, to = 0
      @from = from
      @to = to
    end

    def print name
      diff = to - from
      diffpct = diff == 0 ? 0 : 100.0 * diff / from
      
      printf "%8d %8d %8d %8.1f%% %s\n", from, to, diff, diffpct, name
    end

    def << diff
      @from += diff.from
      @to += diff.to
    end
  end
end
