#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/util'
require 'pvn/command'
require 'pvn/revision'
require 'pvn/cmdargs'
require 'pvn/options'
require 'pvn/diff'

module PVN
  class LogCommand < Command
    subcommands %w{ log l }
    description "Print log messages for the given files."
    usage "[OPTIONS] FILE..."
    # summary 

    def self.subcommands
      %w{ log l }
    end

    def self.description      
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

    DEFAULT_LIMIT = 5

    has_option :limit, '-l', :default => DEFAULT_LIMIT, :negate => [ %r{^--no-?limit} ]
    has_revision_option

    # yes, there's more to it ...
    LOG_REVISION_LINE = Regexp.new('^r(\d+)\s*\|\s*(\w+)')
    
    def run
    end

    def svncommand
      "log"
    end
  end
end
