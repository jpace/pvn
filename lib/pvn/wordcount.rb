#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/command/command'

module PVN
  class WordCount
    attr_accessor :local
    attr_accessor :svn
    attr_accessor :name

    def initialize args = Hash.new
      @name  = args[:name]  || ""
      @local = args[:local] || 0
      @svn   = args[:svn]   || 0
    end

    def +(other)
      # the new wc has the name of the lhs of the add:
      WordCount.new :local => @local + other.local, :svn => @svn + other.svn, :name => @name
    end

    def diff
      @local - @svn
    end

    def diffpct
      @svn.zero? ? "0" : 100.0 * diff / @svn
    end

    def write
      printf "%8d %8d %8d %8.1f%% %s\n", @svn, @local, diff, diffpct, @name
    end
  end
end
