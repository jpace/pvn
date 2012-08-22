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
    end

    def revision
      @optset.revision.value
    end

    def limit
      @optset.limit.value
    end

    def verbose
      @optset.verbose.value
    end

    def help
      @optset.help.value
    end

    def format
      @optset.format.value
    end

    def process_args args
      info "args: #{args}"

      options_processed = Array.new
      
      while !args.empty?
        info "args: #{args}"
        processed = false
        @optset.options.each do |opt|
          info "opt: #{opt}"
          if opt.process args
            info "processed!"
            processed = true
            varname = '@' + opt.name.to_s
            info "varname: #{varname}"
            info "opt.value: #{opt.value}"
            instance_variable_set varname, opt.value
            options_processed << opt
          end
        end

        break unless processed
      end

      info "args: #{args}"

      info "@revision: #{@revision}"

      @path = args[0] || "."

      info "@path: #{path}"

      options_processed.each do |opt|
        info "opt: #{opt}"
        opt.post_process @optset, args

        info "opt: #{opt.value}"
        
        varname = '@' + opt.name.to_s
        info "varname: #{varname}"
        info "opt.value: #{opt.value}"
        
        instance_variable_set varname, opt.value
      end
    end
  end
end
