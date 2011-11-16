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
    
    def initialize args = Hash.new
      info "args: #{args}"
      cmdargs = args[:command_args] || Array.new
      execute = args[:execute].nil? ? true : args[:execute]
      @executor = args[:executor]
      
      limit    = DEFAULT_LIMIT
      revision = nil

      logargs = Array.new
      logargs << "log"
      logargs << "-l"
      logargs << (args[:limit] || "5")

      info "args: #{args}"

      while cmdargs.length > 0
        arg = cmdargs.shift
        info "arg: #{arg}"

        if arg == '-r' && cmdargs.length > 0
          revarg = cmdargs.shift
          info "revarg: #{revarg}"
          rev = to_revision(revarg, cmdargs[-1])
          info "rev: #{rev}"

          if rev.nil?
            raise ArgumentError.new "invalid revision: #{revarg} on #{cmdargs[-1]}"
          end

          info "args: #{args}".green

          logargs << '-r'
          logargs << rev
        elsif arg == '-l' && cmdargs.length > 0
          logargs[2] = cmdargs.shift.to_i
        elsif %w{ --no-limit --nolimit }.include?(arg)
          # remove the limit args:
          logargs.delete_at(2)
          logargs.delete_at(1)
        else
          cmdargs.unshift arg
          break
        end        
      end

      logargs.concat(cmdargs)

      args[:command_args] = logargs

      info "args: #{args}"

      super
    end

    def to_revision arg, fname
      args = { :executor => @executor, :fname => fname, :value => arg }
      info "args: #{args}".bold
      Revision.new(args).revision
    end
  end
end
