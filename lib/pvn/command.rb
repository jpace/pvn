#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/options'
require 'pvn/util'
require 'pvn/cmdexec'

module PVN
  class Command
    include Optional
    include Loggable

    def self.has_revision_option options = Hash.new
      allopts = options.dup
      allopts[:setter] = :revision_from_args
      allopts[:regexp] = Regexp.new('^[\-\+]?\d+$')
      has_option :revision, '-r', "revision", allopts
    end
    
    attr_reader :output
    attr_reader :command

    def initialize args = Hash.new
      info "args: #{args}"
      @execute  = args[:execute].nil? || args[:execute]
      @executor = args[:executor] || CommandExecutor.new
      cmdargs   = args[:command_args] || Array.new
      @args     = process_options cmdargs, args
      @command  = "svn " + @args.join(" ")
      
      if @execute
        @output = @executor.run(@command)
      else
        debug "not executing: #{@command}".on_red
      end
    end

    def process_options cmdargs, args
      ca = self.class.make_command_args args

      info "ca: #{ca}".yellow
      
      while cmdargs.length > 0
        info "cmdargs: #{cmdargs}"
        unless process_option ca, cmdargs
          break
        end
      end

      info "ca: #{ca}"
      info "ca.to_a: #{ca.to_a.inspect}"
      info "cmdargs: #{cmdargs}"

      cmd = self.class::COMMAND
      info "cmd: #{cmd}".yellow

      [ self.class::COMMAND ] + ca.to_a + cmdargs
    end

    def process_option ca, cmdargs
      info "cmdargs: #{cmdargs}"
      ca.process self, cmdargs
    end

    def revision_from_args ca, cmdargs
      require 'pvn/revision'
      
      revarg = cmdargs.shift
      rev = Revision.new(:executor => @executor, :fname => cmdargs[-1], :value => revarg).revision
      Log.info "rev: #{rev}"

      if rev.nil?
        raise ArgumentError.new "invalid revision: #{revarg} on #{cmdargs[-1]}"
      end
      rev
    end
  end
end
