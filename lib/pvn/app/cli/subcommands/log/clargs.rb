#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/revision/entry'
require 'svnx/log/command'

module PVN; module App; end; end

module PVN::App
  class CmdLineArgs
    include Loggable

  end
end

module PVN::App::Log
  class CmdLineArgs
    include Loggable

    attr_reader :limit
    attr_reader :path
    attr_reader :revision
    attr_reader :verbose
    attr_reader :help
    attr_reader :format

    def initialize optset, args
      info "optset: #{optset}"

      @optset   = optset

      @limit    = nil
      @revision = nil
      @path     = '.'
      @revargs  = Array.new
      @verbose  = nil
      @help     = nil
      @format   = true

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
      info "@revargs: #{@revargs}"

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

    def save_revision_value revval
      if matches_relative? revval
        @revargs << revval
      else
        @revision = revval
        info "@revision: #{@revision}".yellow
      end
    end

    def find_matching_option arg
      @optset.options.each do |opt|
        info "opt: #{opt}"
        type, matcher = opt.match arg
        info "matcher: #{matcher}".on_black
        if type
          return [ type, matcher, opt ]
        end
      end
      nil
    end
    
    def process_args args
      options = Array.new
      
      while !args.empty?
        arg = args.shift
        info "arg: #{arg}".yellow

        type, matcher, opt = find_matching_option arg
        info "opt: #{opt}"
        info "opt: #{opt.inspect}"

        if opt
          val = nil
          if type == :exact && opt.takes_value?
            val = args.shift
          elsif type == :regexp
            val = arg
          else
            val = true
          end
          options << [ type, opt, val ]
        else
          @path = arg
        end
      end

      info "path: #{@path}".magenta

      options.each do |type, opt, arg|
        info "opt : #{opt.inspect}".magenta
        info "type: #{type}"
        info "arg : #{arg}"

        if type == :negative
          opt.unset
        else
          opt.set_value arg
        end

        info "opt.value: #{opt.value}".green
      end
    end

    def process_args args
      while !args.empty?
        arg = args.shift
        info "arg: #{arg}".yellow

        case arg
        when "--help"
          @help = true
        when "--limit", "-l"
          @limit = args.shift.to_i
        when "--verbose", "-v"
          @verbose = true
        when "--noformat", "-F"
          @format = false
        when "--format", "-f"
          @format = true
        when "-c"
          chgval = args.shift
          raise "option '-c' requires an argument" unless chgval
          save_revision_value chgval
        when %r{-r(.*)}
          save_revision_value Regexp.last_match[1]
        else
          if matches_relative? arg
            @revargs << arg
          else
            @path = arg
          end
        end

        # info "limit: #{@limit}".on_green
      end
    end
  end
end
