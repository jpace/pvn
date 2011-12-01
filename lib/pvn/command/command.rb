#!/usr/bin/ruby -w
# -*- ruby -*-

require 'riel'
require 'rubygems'
require 'pvn/command/cmdexec'
require 'pvn/option/optional'
require 'pvn/util'

$orig_file_loc = Pathname.new(__FILE__).expand_path

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

    def create_option_set args
      optset = self.class.args_to_option_set args
      info "optset: #{optset}".yellow

      optset2 = self.class.get_option_set
      info "optset2: #{optset2}"

      optset3 = self.class.get_optset
      info "optset3: #{optset3}".on_yellow

      args.each do |key, val|
        RIEL::Log.info "key: #{key}; val: #{val}"
        if optset3.has_key? key
          RIEL::Log.info "key: #{key}; val: #{val}"
          optset3.set_arg key, val
        end
      end

      info "optset: #{optset}".yellow
      info "optset3: #{optset3}".yellow

      optset
    end

    def update_option_set optset, cmdargs
      while cmdargs.length > 0
        info "cmdargs: #{cmdargs}"
        info "cmdargs: #{cmdargs}"
        unless optset.process self, cmdargs
          break
        end
      end

      info "optset: #{optset}".on_green
      info "optset.to_a: #{optset.to_a.inspect}".on_green
      info "cmdargs: #{cmdargs}"

      optset.to_a + cmdargs
    end

    def process_options cmdargs, args
      optset = create_option_set args
      info "optset: #{optset}".yellow

      update_option_set optset, cmdargs

      info "optset: #{optset}".on_green
      info "optset.to_a: #{optset.to_a.inspect}".on_green
      info "cmdargs: #{cmdargs}"

      optset.to_a + cmdargs
    end

    def revision_from_args ca, cmdargs
      require $orig_file_loc.dirname.parent + 'revision.rb'

      revarg = cmdargs.shift
      RIEL::Log.info "revarg: #{revarg}".on_blue
      RIEL::Log.info "cmdargs: #{cmdargs}".on_blue

      rev = Revision.new(:executor => @executor, :fname => cmdargs[-1], :value => revarg, :use_cache => false).revision
      RIEL::Log.info "rev: #{rev}".on_cyan

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
