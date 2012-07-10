#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'system/command/line'

module SVNx
  class StatusCommandLine < System::CommandLine
    def initialize args = Array.new
      info "args: #{args}".cyan
      cmdargs = %w{ svn status --xml }.concat args
      super cmdargs
    end
  end

  class StatusCommandArgs
    attr_accessor :path

    def initialize args = Hash.new
      @path = args[:path]
    end

    def to_a
      [ @path ].compact
    end
  end  

  class StatusCommand
    include Loggable

    attr_reader :output
    
    def initialize args = Hash.new
      info "args: #{args.inspect}".blue
      
      @cmdargs = args[:cmdargs] ? args[:cmdargs].to_a : Array.new
    end

    def command_line
      StatusCommandLine.new @cmdargs
    end
    
    def execute
      cmdline = command_line
      info "cmdline: #{cmdline}".cyan
      cmdline.execute
      info "cmdline.output: #{cmdline.output}".cyan
      
      @output = cmdline.output
    end
  end
end
