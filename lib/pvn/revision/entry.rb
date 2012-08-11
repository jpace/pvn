#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/log/logcmd'
require 'svnx/log/entries'
require 'pvn/revision/argument'

module PVN
  # Returns the Nth revision from the given logging output.

  # -n means to count from the end of the list.
  # +n means to count from the beginning of the list.
  #  n means the literal revision number.  
  module Revisionxxx
    DATE_REGEXP = Regexp.new('^\{(.*?)\}')
    SVN_REVISION_WORDS = %w{ HEAD BASE COMMITTED PREV }

    class Entry
      include Loggable

      attr_reader :value

      def initialize args = Hash.new
        arg = Argument.new args[:value]        
        if arg.relative?
          set_as_relative arg, args[:xmllines]
        else
          @value = arg.value
        end
      end

      def set_as_relative arg, xmllines
        raise "cannot determine relative revision without xmllines" unless xmllines

        logentries = SVNx::Log::Entries.new :xmllines => xmllines

        # logentries are in descending order, so the most recent one is index 0
        info "logentries: #{logentries.size}".red

        val = arg.value

        if val > logentries.size
          @value = nil
        else
          idx = arg.negative? ? -1 + val : logentries.size - val
          logentry = logentries[idx]
          @value = logentry.revision.to_i
        end
      end
    end
  end
end
