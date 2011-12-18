#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/command/command'
require 'pvn/command/cachecmd'
require 'pvn/log/logfactory'

module PVN
  DEFAULT_LIMIT = 5

  class LimitOption < Option
    def initialize lmtargs = Hash.new
      super :limit, '-l', "the number of log entries", :default => DEFAULT_LIMIT, :negate => [ %r{^--no-?limit} ]
    end
  end

  class LogOptionSet < OptionSet
    attr_accessor :revision
    
    def initialize
      super

      self << LimitOption.new
      self << (@revision = RevisionOption.new :unsets => :limit)
    end
  end

  class LogCommand < CachableCommand
    DEFAULT_LIMIT = 5
    COMMAND = "log"
    REVISION_ARG = '-r'

    attr_reader :options

    self.doc do |doc|
      doc.subcommands = [ COMMAND, 'l' ]
      doc.description = "Print log messages for the given files."
      doc.usage       = "[OPTIONS] FILE..."
      doc.summary     = [ "Prints log messages for the given files.",
                          "If a string without a preceding option is given, and is not",
                          "a file name, then it will be used as the comment.",
                          "Prior to executing commit against Subversion, the \"check\"",
                          "command will be run against the given files." ]
      doc.examples   << [ "pvn log foo.rb", "Prints the log for foo.rb, with the default limit of #{DEFAULT_LIMIT}." ]
    end
    
    def initialize args = Hash.new
      @options = LogOptionSet.new
      
      debug "args: #{args.inspect}"

      @options.revision.fromdate = args[:fromdate]
      @options.revision.todate = args[:todate]

      super
    end

    def use_cache?
      # use cache unless log is to head.
      super && !@options.revision.head?
    end

    def to_svn_revision_date date
      '{' + date.to_s + '}'
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
