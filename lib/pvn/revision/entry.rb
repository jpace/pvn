#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/log/logcmd'
require 'svnx/log/entries'

module PVN
  # Returns the Nth revision from the given logging output.

  # -n means to count from the end of the list.
  # +n means to count from the beginning of the list.
  #  n means the literal revision number.  
  module Revisionxxx
    class Entry
      include Loggable

      DATE_REGEXP = Regexp.new('^\{(.*?)\}')
      SVN_REVISION_WORDS = %w{ HEAD BASE COMMITTED PREV }

      attr_reader :number

      def initialize args = Hash.new
        if xmllines = args[:xmllines]
          logentries = SVNx::Log::Entries.new :xmllines => xmllines
          logentries.each do |logentry|
            info "logentry: #{logentry}".cyan
          end
          @number = args[:number]
        end
      end
    end
  end
end
