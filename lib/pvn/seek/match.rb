#!/usr/bin/ruby -w
# -*- ruby -*-

require 'riel/log/loggable'

module PVN::Seek
  class Match
    include RIEL::Loggable

    attr_reader :lnums
    attr_reader :contents
    attr_reader :current_entry
    attr_reader :previous_entry
    
    def initialize lnums, contents, previous_entry, current_entry
      @lnums = lnums
      @contents = contents
      @previous_entry = previous_entry
      @current_entry = current_entry
    end

    def lines
      @lnums.collect { |lnum| @contents[lnum] }
    end

    def decorate path, fromrev, torev
      [ path.to_s.color(:yellow), fromrev.color(:magenta), torev.color(:green) ]
    end
    
    def show path, use_color
      # todo: run through entry formatter in log

      fromrev = current_entry.revision
      torev   = previous_entry.revision

      pathstr, fromrevstr, torevstr = use_color ? decorate(path, fromrev, torev) : [ path.to_s, fromrev, torev ]
      pathrev = "#{pathstr} -r#{fromrevstr}:#{torevstr}"
      $io.puts pathrev
      
      @lnums.each do |lnum|
        line = @contents[lnum]
        linestr = use_color ? line.chomp.bright : line.chomp
        line = "#{lnum + 1}: #{linestr}"
        $io.puts line
      end
    end

    def to_s
      "[#{lnums}]: #{lines}; prev: #{previous_entry && previous_entry.revision}; curr: #{current_entry && current_entry.revision}"
    end

    def has_line? line
      @lnums.detect { |lnum| @contents[lnum].index line }
    end

    def diff othermatch
      otherlnums = othermatch.lnums
      currlnums = lnums

      diff = Array.new
      lnums.each do |lnum|
        line = @contents[lnum]
        unless othermatch.has_line? line
          diff << [ lnum, line ]
        end
      end
      diff
    end
  end
end
