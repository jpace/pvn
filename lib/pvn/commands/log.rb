#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/commands/cachecmd'

module PVN
  module Logx
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
        puts "name: #{name.inspect}"
        self.instance_variable_set '@' + name.to_s, args[name]
      end

      LOG_RE = Regexp.new('^r(\d+) \| (\S+) \| (\S+) (\S+) (\S+) \((.*)\) \| (\d+) lines?$')
      LOG_SEPARATOR_RE = Regexp.new('^-{72}$')

      # reads a log entry from the text, starting at lidx, or returns nil if the
      # text does not match the expected plain text format.
      def self.create_from_terse_text lines, lidx = 0
        if lines[lidx] == LOG_SEPARATOR_LINE && lidx + 1 < lines.length
          # fields = LOG_RE.match(
        end
        nil
      end

      def initialize args = Hash.new
        FIELDS.each do |field|
          set_from_args field, args
        end
      end
    end

    class Command < CachableCommand
      def initialize args
        command = %w{ svn log }

        # todo: handle revision conversion:
        fromrev = args[:fromrev]
        torev   = args[:torev]

        if fromrev && torev
          command << "-r" << "#{fromrev}:#{torev}"
        elsif args[:fromdate] && args[:todate]
          command << "-r" << "\{#{fromdate}\}:\{#{todate}\}"
        end
        info "command: #{command}".on_red
      end
    end
  end
end
