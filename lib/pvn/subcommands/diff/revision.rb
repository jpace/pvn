#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/revision'

module PVN::Subcommands::Diff
  class RevisionRange < PVN::RevisionRange
    include Loggable

    def initialize change, rev
      if change
        super change.to_i - 1, change.to_i
      elsif rev.kind_of? Array
        if rev.size == 2
          # this is some contorting, since -rx:y does not mean comparing the files
          # in changelist x; it means all the entries from x+1 through y, inclusive.

          ### $$$ this doesn't handle dates:
          super rev[0].to_i + 1, rev[0].to_i
        else
          from, to = rev[0].split(':')
          info "from: #{from}"
          info "to  : #{to}"
          super from.to_i + 1, to
        end
      else
        raise "revision argument not handled: #{rev}"
      end
    end
  end
end
