#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/revision/range'

module PVN::Diff
  class RevisionRange < PVN::Revision::Range
    include Loggable, Comparable

    def initialize change, rev
      if change
        super change.to_i - 1, change.to_i
      elsif rev.kind_of? Array
        if rev.size == 2
          # this is some contorting, since -rx:y does not mean comparing the files
          # in changelist x; it means all the entries from x+1 through y, inclusive.

          super rev[0], rev[1]
        else
          from, to = rev[0].split(':')
          info "from: #{from}"
          info "to  : #{to}".cyan
          super from, to
        end
      else
        raise "revision argument not handled: #{rev}"
      end
    end

    def <=> other
      info "other: #{other}".yellow
      info "self: #{self}".yellow
      nil
    end
  end
end
