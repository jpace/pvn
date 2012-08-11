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
        val = args[:value]
        info "val: #{val}"

        arg = Argument.new val
        info "arg: #{arg}".blue

        @value = arg.value

        if xmllines = args[:xmllines]
          logentries = SVNx::Log::Entries.new :xmllines => xmllines
          logentries.each do |logentry|
            info "logentry: #{logentry}".cyan
          end
          # @value = args[:value]
        end
      end
    end
  end
end
