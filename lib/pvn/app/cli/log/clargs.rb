#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/revision/entry'

module PVN; module App; end; end

module PVN::App::Log
  class CmdLineArgs
    include Loggable

    attr_reader :limit
    attr_reader :path
    attr_reader :revision
    attr_reader :verbose

    def initialize args
      @limit    = nil
      @revision = nil
      @path     = '.'
      @revargs  = Array.new
      @verbose  = nil

      # we have to process all arguments before resolving the revision,
      # since the revision needs the path.
      
      ### $$$ todo: decide whether/how to support multiple paths.

      process_args args
      process_revision
    end

    def matches_relative? str
      PVN::Revisionxxx::Entry::matches_relative? str
    end

    def process_revision
      return nil if @revargs.empty?

      logforrev = SVNx::LogCommandLine.new @path
      logforrev.execute
      xmllines = logforrev.output

      @revargs.each do |revarg|
        reventry = PVN::Revisionxxx::Entry.new :value => revarg, :xmllines => xmllines.join('')
        revval   = reventry.value.to_s

        if @revision
          @revision << ":" << revval
        else
          @revision = revval
        end
      end
    end

    def process_args args
      while !args.empty?
        arg = args.shift
        case arg
        when "--limit", "-l"
          @limit = args.shift.to_i
        when "--verbose", "-v"
          @verbose = true
        when %r{-r(.*)}
          revval = Regexp.last_match[1]
          if matches_relative? revval
            @revargs << revval
          else
            @revision = revval
          end
        else
          if matches_relative? arg
            @revargs << arg
          else
            @path = arg
          end
        end
      end
    end
  end
end
