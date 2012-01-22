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

    def self.has_revision_option revopts = Hash.new
      options << RevisionRegexpOption.new(revopts)
    end
    
    def self.revision_from_args optset, cmdargs
      require 'pvn/revision'
      Revision.revision_from_args optset, cmdargs
    end

    attr_reader :output

    def initialize args = Hash.new
      debug "args: #{args}"
      @execute  = args[:execute].nil? || args[:execute]
      @executor = args[:executor] || CommandExecutor.new
      
      options.process self, args, args[:command_args] || Array.new
      
      execute
    end

    def get_command_line args
      fullcmdargs = options.to_command_line + options.arguments
      info "fullcmdargs: #{fullcmdargs}"

      fullcmdargs
    end

    def execute
      # see SVNCommand#execute
      raise "abstract method invoked"
    end

    def command
      raise "abstract method invoked"
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

    def has_entries?
      false
    end

    def options
      # self.class.options
    end
  end
end
