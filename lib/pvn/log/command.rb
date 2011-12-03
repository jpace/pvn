#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/command/command'
require 'pvn/command/cachecmd'
require 'pvn/log/factory'

module PVN
  class LogCommand < CachableCommand
    DEFAULT_LIMIT = 5

    # yes, there's more to it ...
    LOG_REVISION_LINE = Regexp.new('^r(\d+)\s*\|\s*(\w+)')

    COMMAND = "log"

    REVISION_ARG = '-r'

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

    def initialize args = Hash.new
      debug "args: #{args.inspect}".on_yellow

      @fromdate = args[:fromdate]
      @todate = args[:todate]

      super
    end

    def to_svn_revision_date date
      '{' + date.to_s + '}'
    end

    def to_svn_command fullcmdargs
      info "fullcmdargs: #{fullcmdargs}".on_blue

      info "@fromdate: #{@fromdate}".on_blue
      info "@todate: #{@todate}".on_blue

      updated_args = fullcmdargs.dup

      if @fromdate && @todate
        revarg = REVISION_ARG + to_svn_revision_date(@fromdate) + ':' + to_svn_revision_date(@todate)
        updated_args.insert 0, revarg
      end

      super updated_args
    end

    def entries
      # of course this assumes that output is in plain text (non-XML)
      factory = PVN::Log::TextFactory.new output
      factory.entries
    end
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
        debug "command: #{command}".on_red
      end
    end
  end
end
