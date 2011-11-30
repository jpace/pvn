#!/usr/bin/ruby -w
# -*- ruby -*-

require 'riel'
require 'rubygems'
require 'pvn/command/cmdexec'
require 'pvn/option/optional'
require 'pvn/util'

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

    def initialize args = Hash.new
      info "args: #{args}"
      @execute  = args[:execute].nil? || args[:execute]
      @executor = args[:executor] || CommandExecutor.new
      cmdargs   = args[:command_args] || Array.new
      @args     = process_options cmdargs, args
      @fullargs = [ "svn", self.class::COMMAND ] + @args

      run @fullargs
    end

    def command
      @fullargs.join(" ")
    end

    def run args
      info "self.class: #{self.class}"
      info "@command  : #{command}".on_black
      info "@execute  : #{@execute}".on_black

      if @execute
        info "@executor : #{@executor}"
        @output = @executor.run(command)
      else
        debug "not executing: #{command}".red
      end
    end

    def process_options cmdargs, args
      ca = self.class.make_command_args args

      info "ca: #{ca}".yellow
      
      while cmdargs.length > 0
        info "cmdargs: #{cmdargs}"
        info "cmdargs: #{cmdargs}"
        unless ca.process self, cmdargs
          break
        end
      end

      info "ca: #{ca}"
      info "ca.to_a: #{ca.to_a.inspect}"
      info "cmdargs: #{cmdargs}"

      ca.to_a + cmdargs
    end

    def revision_from_args ca, cmdargs
      require 'pvn/revision'
      
      revarg = cmdargs.shift
      rev = Revision.new(:executor => @executor, :fname => cmdargs[-1], :value => revarg).revision
      RIEL::Log.info "rev: #{rev}"

      if rev.nil?
        raise ArgumentError.new "invalid revision: #{revarg} on #{cmdargs[-1]}"
      end
      rev
    end

    def option optname
      self.class.find_option optname
    end

    def run_command
      @output = @executor.run(command)
    end
  end
end
