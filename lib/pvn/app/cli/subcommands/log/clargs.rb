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
      # process_revision
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

    def process_args args
      info "args: #{args}"

      options_processed = Array.new
      
      while !args.empty?
        info "args: #{args}"
        processed = false
        @optset.options.each do |opt|
          info "opt: #{opt}".green
          if opt.process args
            info "got processed!"
            processed = true
            varname = '@' + opt.name.to_s
            info "varname: #{varname}"
            info "opt.value: #{opt.value}"
            instance_variable_set varname, opt.value
            options_processed << opt
          else
            info "NOT processed"
          end
        end

        break unless processed
      end

      info "args: #{args}".cyan

      info "@revision: #{@revision}".on_cyan

      @path = args[0] || "."

      info "@path: #{path}".yellow

      options_processed.each do |opt|
        info "opt: #{opt}".on_red
        opt.post_process @optset, args

        if opt.kind_of?(PVN::RevisionRegexpOption)
          info "opt: #{opt}".on_blue
          info "opt: #{opt.value}".on_blue
          @revision = opt.value
        end
      end
    end
    
    def process_args_old args
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
      end
    end
  end
end
