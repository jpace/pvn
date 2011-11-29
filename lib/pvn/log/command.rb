#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/command/command'
require 'pvn/command/cachecmd'

module PVN
  class LogCommand < Command
    DEFAULT_LIMIT = 5

    # yes, there's more to it ...
    LOG_REVISION_LINE = Regexp.new('^r(\d+)\s*\|\s*(\w+)')

    COMMAND = "log"

    subcommands [ COMMAND, 'l' ]
    description "Print log messages for the given files."
    usage "[OPTIONS] FILE..."
    summary [ "  Prints log messages for the given files.",
              "  If a string without a preceding option is given, and is not",
              "  a file name, then it will be used as the comment.",
              "  Prior to executing commit against Subversion, the \"check\"",
              "  command will be run against the given files." ]
    
    examples << [ "pvn log foo.rb", "Prints the log for foo.rb, with the default limit of #{DEFAULT_LIMIT}." ]
    
    has_option :limit, '-l', "the number of log entries", :default => DEFAULT_LIMIT, :negate => [ %r{^--no-?limit} ]
    has_revision_option :unsets => :limit
  end

  module Log
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
