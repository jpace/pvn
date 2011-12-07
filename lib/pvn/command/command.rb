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

    def self.revision_from_args results, cmdargs
      require $orig_file_loc.dirname.parent + 'revision.rb'
      
      Revision.revision_from_args results, cmdargs
    end

    attr_reader :output

    def initialize args = Hash.new
      debug "args: #{args}".red
      @execute  = args[:execute].nil? || args[:execute]
      @executor = args[:executor] || CommandExecutor.new
      cmdargs   = args[:command_args] || Array.new

      optresults  = self.class.args_to_option_results args
      fullcmdargs = update_option_results optresults, cmdargs

      if args[:filename]
        fullcmdargs << args[:filename]
      end

      @svncmd     = to_svn_command fullcmdargs
      run @svncmd
    end

    def to_svn_command fullcmdargs
      [ "svn", self.class::COMMAND ] + fullcmdargs
    end

    def command
      @svncmd.join(" ")
    end

    def run args
      info "self.class: #{self.class}"
      info "@command  : #{command}".on_black
      info "@execute  : #{@execute}".on_black

      if @execute
        info "@executor : #{@executor}"
        @output = @executor.run command
      else
        debug "not executing: #{command}".red
      end
    end

    def update_option_results optresults, cmdargs
      while cmdargs.length > 0
        unless optresults.process self, cmdargs
          break
        end
      end

      info "optresults: #{optresults}"
      info "optresults.values: #{optresults.values.inspect}"
      info "cmdargs: #{cmdargs}"

      optresults.values + cmdargs
    end

    def process_options cmdargs, args
      optresults = self.class.args_to_option_results args
      update_option_results optresults, cmdargs
    end

    def option optname
      self.class.find_option optname
    end

    def run_command
      @output = @executor.run(command)
    end
  end
end
