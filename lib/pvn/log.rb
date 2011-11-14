#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/util'
require 'pvn/command'
require 'pvn/revision'

module PVN
  class LogCommand < Command
    def self.subcommands
      %w{ log l }
    end

    def self.description
      "Print log messages for the given files."
    end

    def self.usage
      "[OPTIONS] FILE..."
    end

    def self.summary
      summary = Array.new
      summary << "  Prints log messages for the given files."
      summary << "  If a string without a preceding option is given, and is not"
      summary << "  a file name, then it will be used as the comment."
      summary << "  Prior to executing commit against Subversion, the \"check\""
      summary << "  command will be run against the given files."
      summary
    end

    def self.examples
      examples = Array.new
      examples << "  % pvn log foo.rb"
      examples << "    Prints the log for foo.rb, with the default limit of #{DEFAULT_LIMIT}."
      examples
    end

    def self.help
      Command.make_help_for self
    end    

    # yes, there's more to it ...
    LOG_REVISION_LINE = Regexp.new('^r(\d+)\s*\|\s*(\w+)')

    DEFAULT_LIMIT = 5
    
    def initialize(args = Hash.new)
      cmdargs = args[:command_args]
      
      limit    = DEFAULT_LIMIT
      revision = nil

      ai = 0
      while ai < cmdargs.length
        arg = cmdargs[ai]

        if arg == '-r' && ai + 1 < cmdargs.length
          ai += 1
          rev = to_revision(cmdargs[ai], cmdargs[-1])

          if rev.nil?
            raise ArgumentError.new "invalid revision: #{cmdargs[ai]} on #{cmdargs[-1]}"
          end

          cmdargs[ai] = rev
        elsif arg == '-l' && ai + 1 < cmdargs.length
          ai += 1
          limit = cmdargs[ai]
        elsif num = Util.negative_integer?(arg)
          info "looking for revision #{num}"

          revision = to_revision(arg, cmdargs[-1])

          ## and insert -r into args list
        end
        
        ai += 1
      end

      super(:execute => true, :command_args => [ "log", "-l", limit ] | cmdargs)
    end

    def to_revision(arg, fname)
      RevisionCommand.new(arg, fname).revision
    end

  end

end
