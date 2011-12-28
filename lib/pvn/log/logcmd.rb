#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/command/command'
require 'pvn/command/svncmd'
require 'pvn/command/cachecmd'
require 'pvn/log/logfactory'
require 'pvn/option/boolopt'

module PVN
  DEFAULT_LIMIT = 5

  class LimitOption < Option
    def initialize lmtargs = Hash.new
      super :limit, '-l', "the number of log entries", :default => DEFAULT_LIMIT, :negate => [ %r{^--no-?limit} ]
    end
  end

  class VerboseOption < BooleanOption
    def initialize optargs = Hash.new
      super :verbose, '-v', "print additional output", :default => false
    end
  end

  class LogOptionSet < OptionSet
    attr_accessor :revision
    
    def initialize
      super

      add LimitOption.new
      @revision = add RevisionOption.new(:unsets => :limit)
      @verbose  = add VerboseOption.new
    end
  end

  class LogCommand < SVNCommand
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

      @entries = nil

      super
    end

    def has_entries?
      true
    end

    def use_cache?
      # use cache unless log is to head.
      super && !@options.revision.head?
    end

    def to_svn_revision_date date
      '{' + date.to_s + '}'
    end

    def entries
      @entries ||= begin
                     # of course this assumes that output is in plain text (non-XML)
                     factory = PVN::Log::TextFactory.new output
                     factory.entries
                   end
    end

    def revision_of_nth_entry num
      entry = nth_entry num
      entry && entry.revision.to_i
    end

    def nth_entry n
      entries[-1 * n]
    end

    # this may be faster than get_nth_entry
    def read_from_log_output n_matches
      loglines = output.reverse

      entries = entries
      entry = entries[-1 * n_matches]
      
      if true
        return entry && entry.revision.to_i
      end

      loglines.each do |line|
        next unless md = SVN_LOG_SUMMARY_LINE_RE.match(line)
        
        info "md: #{md}".yellow
        
        n_matches -= 1
        if n_matches == 0
          return md[1].to_i
        end
      end
      nil
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
