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

    def self.has_argument tag, varname, *args
      puts "tag: #{tag}".on_blue
      puts "varname: #{varname}".on_blue
      puts "args: #{args}".on_blue
    end

    has_argument '-l', :limit, :type => :numeric, :default => 5

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

      logargs = Hash.new
      logargs[:limit] = (args[:limit] || "5")

      info "args: #{args}"

      while cmdargs.length > 0
        arg = cmdargs.shift
        info "arg: #{arg}"

        if arg == '-r' && cmdargs.length > 0
          update_revision_arg logargs, cmdargs
        elsif arg == '-l' && cmdargs.length > 0
          logargs[:limit] = cmdargs.shift.to_i
        elsif %w{ --no-limit --nolimit }.include?(arg)
          remove_limit_arg logargs
        else
          cmdargs.unshift arg
          break
        end        
      end

      allargs = Array.new
      allargs << "log"
      if logargs[:limit]
        allargs << '-l' << logargs[:limit]
      end

      if logargs[:revision]
        allargs << '-r' << logargs[:revision]
      end

      allargs.concat(cmdargs)

      args[:command_args] = allargs

      info "args: #{args}"

      super
    end

    def remove_limit_arg logargs
      logargs[:limit] = nil
    end

    def update_revision_arg logargs, cmdargs
      revarg = cmdargs.shift
      info "revarg: #{revarg}"
      rev = to_revision(revarg, cmdargs[-1])
      info "rev: #{rev}"

      if rev.nil?
        raise ArgumentError.new "invalid revision: #{revarg} on #{cmdargs[-1]}"
      end

      logargs[:revision] = rev
    end

    def to_revision arg, fname
      args = { :executor => @executor, :fname => fname, :value => arg }
      info "args: #{args}".bold
      Revision.new(args).revision
    end
  end
end
