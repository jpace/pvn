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

    def create_option_results args
      optresults = self.class.args_to_option_results args
      info "optresults: #{optresults}".yellow
      
      optresults
    end

    def update_option_results optresults, cmdargs
      while cmdargs.length > 0
        unless optresults.process self, cmdargs
          break
        end
      end

      info "optresults: #{optresults}"
      info "optresults.to_a: #{optresults.to_a.inspect}"
      info "cmdargs: #{cmdargs}"

      optresults.to_a + cmdargs
    end

    def process_options cmdargs, args
      optresults = create_option_results args
      info "optresults: #{optresults}".yellow

      update_option_results optresults, cmdargs
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
