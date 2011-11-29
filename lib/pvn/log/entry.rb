#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

module PVN
  module Log
    class Entry
      FIELDS = [ :revision,
                 :user,
                 :date,
                 :time,
                 :tz,
                 :dtg,
                 :nlines,
                 :files,
                 :comment ]

      FIELDS.each do |field|
        attr_reader field
      end

      def set_from_args name, args
        self.instance_variable_set '@' + name.to_s, args[name]
      end

      # Reads a log entry from the text, starting at the first line at or after
      # lidx, matching the svn log separator line. Returns [ entry, new_index ],
      # where new_index is the updated index into the lines. Returns nil if the
      # text does not match the expected plain text format.
      def self.create_from_text lines, lidx = 0
        return TextOutputReader.create_from_text lines, lidx
      end

      def initialize args = Hash.new
        FIELDS.each do |field|
          set_from_args field, args
        end
      end
    end
  end
end
