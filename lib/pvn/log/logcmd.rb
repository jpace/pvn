#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/command/command'
require 'pvn/command/cachecmd'
require 'pvn/log/logfactory'

module PVN
  DEFAULT_LIMIT = 5

  class RevisionOption < Option
    def initialize revargs = Hash.new
      revargs[:setter] = :revision_from_args
      revargs[:regexp] = Regexp.new('^[\-\+]?\d+$')
      
      super :revision, '-r', "revision", revargs
    end
  end

  class LimitOption < Option
    def initialize lmtargs = Hash.new
      super :limit, '-l', "the number of log entries", :default => DEFAULT_LIMIT, :negate => [ %r{^--no-?limit} ]
    end
  end

  class LogOptionSet < OptionSet
    @@orig_file_loc = Pathname.new(__FILE__).expand_path
    
    def initialize
      super

      self << LimitOption.new
      self << RevisionOption.new(:unsets => :limit)
    end

    def revision_from_args results, cmdargs
      require @@orig_file_loc.dirname.parent + 'revision.rb'
      Revision.revision_from_args results, cmdargs
    end
  end

  class LogCommand < CachableCommand
    DEFAULT_LIMIT = 5

    COMMAND = "log"

    REVISION_ARG = '-r'

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
    
    # has_option :limit, '-l', "the number of log entries", :default => DEFAULT_LIMIT, :negate => [ %r{^--no-?limit} ]
    # has_revision_option :unsets => :limit

    def options
      @options
    end

    def initialize args = Hash.new
      @options = LogOptionSet.new
      
      debug "args: #{args.inspect}"

      @fromdate = args[:fromdate]
      @todate = args[:todate]

      super
    end

    def to_svn_revision_date date
      '{' + date.to_s + '}'
    end

    def to_svn_command fullcmdargs
      info "fullcmdargs: #{fullcmdargs}"

      info "@fromdate: #{@fromdate}"
      info "@todate: #{@todate}"

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
