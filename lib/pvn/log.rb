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
      cmdargs = args[:command_args] || Array.new
      execute = args[:execute].nil? ? true : args[:execute]
      
      limit    = DEFAULT_LIMIT
      revision = nil

      logargs = Array.new
      logargs << "log"

      while cmdargs.length > 0
        arg = cmdargs.shift
        if arg == '-r' && cmdargs.length > 1
          cmdargs.shift
          revarg = cmdargs.shift
          rev = to_revision(revarg, cmdargs[-1])

          if rev.nil?
            raise ArgumentError.new "invalid revision: #{revarg} on #{cmdargs[-1]}"
          end

          logargs << 'r'
          logargs << rev
        elsif arg == '-l' && cmdargs.length > 0
          limit = cmdargs.shift
        elsif %w{ --no-limit --nolimit }.include?(arg)
          limit = nil
        else
          cmdargs.unshift arg
          break
        end        
      end

      logargs.concat([ '-l', limit ]) if limit
      logargs.concat(cmdargs)

      super(:execute => args[:execute], :command_args => logargs)
    end

    def to_revision(arg, fname)
      RevisionCommand.new(arg, fname, self.class).revision
    end
  end
end
