#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/linecount'
require 'pvn/io'
require 'pvn/util'

module PVN
  # An element unites an svn element and a file/directory (at least one of which
  # should exist).
  class Element
    include Loggable

    attr_reader :svn
    attr_reader :local
    
    def initialize args = Hash.new
      @svn   = args[:svn]   || (args[:file] && SVNElement.new(:name => args[:file]))
      @local = args[:local] || (args[:file] && FSElement.new(args[:file]))
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
    
    def line_counts
      [ @svnelement && @svnelement.line_count, @fselement & @fselement.line_count ]
    end

    def <=>(other)
      @svn <=> other.svn
    end
  end
end
