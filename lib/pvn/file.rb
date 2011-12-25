#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/linecount'
require 'pvn/io'
require 'pvn/util'

module PVN
  class File < ::File
    include Loggable
    
    def initialize args
      @fname = args[:fname]
    end

    def to_command subcmd, revcl, *args
      cmd = "svn #{subcmd}"
      info "cmd: #{cmd}".on_blue
      info "args: #{args}".on_blue
      args = args.flatten

      # revcl is [ -r, 3484 ]
      if revcl
        cmd << " " << revcl.join(" ")
      end
      cmd << " " << Util::quote_list(args)
      info "cmd: #{cmd}".on_blue
      cmd
    end

    def line_count_in_svn
      lc = nil
      
      cmd = to_command "cat", nil, @fname
      ::IO.popen cmd do |io|
        lc = IO::numlines io
        info "lc: #{lc.inspect}"
      end

      lc
    end
  end
end
