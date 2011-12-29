#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/io'
require 'pvn/util'
require 'pvn/svn/svninfo'

module PVN
  class SVNElement
    include Loggable
    attr_reader :name
    
    def initialize args
      RIEL::Log.info "args: #{args}".green
      @name = args[:name]
      RIEL::Log.info "@name: #{@name}".green
    end

    def to_command subcmd, revcl, *args
      cmd = "svn #{subcmd}"
      debug "cmd: #{cmd}".on_blue
      debug "args: #{args}".on_blue
      args = args.flatten

      # revcl is [ -r, 3484 ]
      if revcl
        cmd << " -r #{revcl}"
      end
      cmd << " " << Util::quote_list(args)
      debug "cmd: #{cmd}".on_blue
      cmd
    end

    def info
      SVN::Info.new :name => @name
    end

    def line_count revision = nil
      lc = nil
      
      cmd = to_command "cat", revision, @name
      ::IO.popen cmd do |io|
        lc = IO::numlines io
        debug "lc: #{lc.inspect}"
      end

      lc
    end
    
    def to_s
      @name.to_s
    end

    def inspect
      @name
    end

    def <=>(other)
      debug "@name: #{@name}".green
      @name <=> other.name
    end
  end
end
