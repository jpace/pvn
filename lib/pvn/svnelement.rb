#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/linecount'
require 'pvn/io'
require 'pvn/util'

module PVN
  class SVNElement
    include Loggable
    attr_reader :name
    
    def initialize args
      RIEL::Log.info "args: #{args}".green
      @name = args[:name]
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
      cmd = "svn info #{name}"
      output = %x{#{cmd}}
      debug "output: #{output}".on_black
      debug "output: #{output.class}".on_black

      re = Regexp.new '^(.*?):\s*(.*)'
      
      info = Hash.new
      output.split("\n").each do |line|
        key, value = re.match(line)[1, 2]
       
        debug "key: #{key}"
        debug "value: #{value}"

        keysym = key.downcase.gsub(' ', '_').to_sym
        debug "keysym: #{keysym}"

        info[keysym] = value
      end
      info
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

    def <=>(other)
      debug "@name: #{@name}".green
      @name <=> other.name
    end
  end
end
