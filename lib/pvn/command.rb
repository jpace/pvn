#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/util'
require 'pvn/cmdexec'
require 'pvn/options'
# require 'pvn/doc'

module PVN
  class Command
    include Optional
    include Loggable
    # include Doc

    def self.has_revision_option
      has_option :revision, '-r', "revision", :setter => :revision_from_args
    end
    
    def self.make_help(subcommands, description)
      help = Array.new

      subcmdstr = subcommands[0]
      if subcommands.size > 1
        subcmdstr << " (" << subcommands[1 .. -1].join(" ") << ")"
      end
      
      help << subcmdstr + ": " + description
    end
    
    def self.make_help_for(cls)
      help = Array.new

      subcmds = cls.subcommands

      subcmdstr = subcmds[0].dup
      if subcmds.size > 1
        subcmdstr << " (" << subcmds[1 .. -1].join(" ") << ")"
      end

      help << subcmdstr + ": " + cls.description
      help << "usage: " + subcmds[0] + " " + cls.usage
      help << ""
      help.concat cls.summary

      Log.debug "cls: #{cls}"

      if cls.respond_to? :options
        options = cls.options

        if options
          help << ""
          Log.debug "options: #{options}"
          help << "Options:"
          help << ""
          
          options.each do |opt|
            Log.debug "opt: #{opt}"

            opttag  = opt[0]
            optdesc = opt[1]

            Log.debug "opttag: #{opttag}"
            Log.debug "optdesc: #{optdesc}"

            # wrap optdesc?

            optdesc.each_with_index do |descline, idx|
              lhs = if idx == 0
                      sprintf("%-24s :", opttag)
                    else
                      " " * 26
                    end
              optstr = sprintf "  %4s %s", lhs, descline

              help << optstr
            end
            
#       options << "  -e [--execute]       : Detect local files that have been added and removed,"
#       options << "                         and update Subversion to reflect that."
            
          end
        end
      end

      help << ""
      help << "Examples:"
      help << ""
      help.concat cls.examples

      help
    end
    
    attr_reader :output
    attr_reader :command

    def initialize args = Hash.new
      info "args: #{args}"
      @execute  = args[:execute].nil? || args[:execute]
      @executor = args[:executor] || CommandExecutor.new

      cmdargs = args[:command_args] || Array.new

      @args = process_options cmdargs, args

      @command = "svn " + @args.join(" ")
      info "@command: #{@command}"
      info "@executor: #{@executor}"
      if @execute
        @output = @executor.run(@command)
      else
        debug "not executing: #{@command}".on_red
      end
    end

    def process_options cmdargs, args
      ca = self.class.make_command_args args
      
      while cmdargs.length > 0
        info "cmdargs: #{cmdargs}"
        unless process_option ca, cmdargs
          break
        end
      end

      info "ca: #{ca}"
      info "ca.to_a: #{ca.to_a.inspect}"
      info "cmdargs: #{cmdargs}"

      allargs = Array.new
      cmd = self.class::COMMAND
      info "cmd: #{cmd.inspect}".yellow
      allargs << cmd
      allargs.concat ca.to_a
      allargs.concat cmdargs

      allargs
    end

    def process_option ca, cmdargs
      arg = cmdargs.shift
      info "arg: #{arg}"
      info "cmdargs: #{cmdargs}"

      if ca.process self, arg, cmdargs
        true
      else
        cmdargs.unshift arg
        false
      end
    end

    def revision_from_args cmdargs
      revarg = cmdargs.shift
      Log.info "revarg: #{revarg}".on_blue
      Log.info "@executor: #{@executor}".on_blue

      rev = Revision.new(:executor => @executor, :fname => cmdargs[-1], :value => revarg).revision
      Log.info "rev: #{rev}"

      if rev.nil?
        raise ArgumentError.new "invalid revision: #{revarg} on #{cmdargs[-1]}"
      end
      rev
    end
  end
end
