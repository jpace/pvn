#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/util'
require 'pvn/command'
require 'pvn/revision'
require 'pvn/cmdargs'

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

    @@options = Array.new    

    def self.has_option optname, tag, args = Hash.new
      @@options << [ optname, tag, args ]
    end

    DEFAULT_LIMIT = 5

    has_option :limit,    '-l', :default => DEFAULT_LIMIT, :type => :integer, :setter => :get_next_argument_as_integer, :negate => [ %r{^--no-?limit} ]
    has_option :revision, '-r', :setter => :revision_from_args

    def self.make_command_args args
      ca = CommandArgs.new
      @@options.each do |opt|
        ca.add_known_arg(*opt)
      end
      args.each do |key, val|
        Log.info "key: #{key}; val: #{val}".yellow
        if ca.has_key? key
          Log.info "key: #{key}; val: #{val}".magenta
          ca.set_arg key, val
        end
      end
      ca
    end      

    # yes, there's more to it ...
    LOG_REVISION_LINE = Regexp.new('^r(\d+)\s*\|\s*(\w+)')
    
    def initialize args = Hash.new
      info "args: #{args}"
      cmdargs = args[:command_args] || Array.new
      execute = args[:execute].nil? || args[:execute]
      @executor = args[:executor]

      args[:command_args] = process_options cmdargs, args

      info "args: #{args}"

      super
    end

    def svncommand
      "log"
    end

    def revision_from_args cmdargs
      revarg = cmdargs.shift
      Log.info "revarg: #{revarg}"
      Log.info "@executor: #{@executor}"

      rev = Revision.new(:executor => @executor, :fname => cmdargs[-1], :value => revarg).revision
      Log.info "rev: #{rev}"

      if rev.nil?
        raise ArgumentError.new "invalid revision: #{revarg} on #{cmdargs[-1]}"
      end
      rev
    end
  end
end
