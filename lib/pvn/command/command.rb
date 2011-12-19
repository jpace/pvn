#!/usr/bin/ruby -w
# -*- ruby -*-

require 'riel'
require 'rubygems'
require 'pvn/command/cmdexec'
require 'pvn/option/optionable'
require 'pvn/option/revopt'
require 'pvn/util'

module PVN
  class Command
    include Optionable
    include Loggable

    @@orig_file_loc = Pathname.new(__FILE__).expand_path

    def self.has_revision_option revopts = Hash.new
      options << RevisionOption.new(revopts)
    end
    
    def self.revision_from_args optset, cmdargs
      require @@orig_file_loc.dirname.parent + 'revision.rb'
      Revision.revision_from_args optset, cmdargs
    end

    attr_reader :output

    def initialize args = Hash.new
      debug "args: #{args}"
      @execute  = args[:execute].nil? || args[:execute]
      @executor = args[:executor] || CommandExecutor.new

      args[:command_args] ||= Array.new

      set_options args
      
      cmdline = get_command_line args
      
      if args[:filename]
        cmdline << args[:filename]
      end

      run_command_line cmdline
    end

    def set_options args
      options.process self, args, args[:command_args]
    end

    def get_command_line args
      fullcmdargs = options.to_command_line + args[:command_args]
      info "fullcmdargs: #{fullcmdargs}"

      fullcmdargs
    end

    def run_command_line cmdline
      @svncmd = to_svn_command cmdline
      run @svncmd
    end

    def to_svn_command fullcmdargs
      [ "svn", self.class::COMMAND ] + fullcmdargs
    end

    def command
      @svncmd.join(" ")
    end

    def to_s
      ""
    end

    def run args
      info "self.class: #{self.class}"
      info "@command  : #{command}"
      info "@execute  : #{@execute}"

      if @execute
        info "@executor : #{@executor}"
        @output = @executor.run command
      else
        debug "not executing: #{command}"
      end
    end

    def option optname
      self.class.find_option optname
    end

    def options
      # self.class.options
    end

    def run_command
      @output = @executor.run(command)
    end
  end
end
