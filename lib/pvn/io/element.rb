#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/base/util'
require 'svnx/log/command'
require 'svnx/log/entries'
require 'svnx/log/xml/xmllog'
require 'svnx/status/command'
require 'svnx/status/entries'
require 'pvn/io/fselement'

module PVN
  module IO

    # An element unites an svn element and a file/directory (at least one of
    # which should exist).

    class Element
      include Loggable

      attr_reader :svn
      attr_reader :local
      
      def initialize args = Hash.new
        info "args: #{args}".negative
        
        svnurl = args[:svnurl]
        fname  = args[:filename] || args[:file] # legacy
        # $$$ todo: map svnurl to SVNElement, and fname to FSElement

        @svn   = args[:svn] || (args[:file] && SVNElement.new(:filename => args[:file]))
        @local = FSElement.new args[:local] || args[:file]
        
        info "local: #{@local}"
      end

      def log cmdargs = SVNx::LogCommandArgs.new
        info "cmdargs: #{cmdargs}".green

        cmdargs.path = @local

        cmd = SVNx::LogCommand.new :cmdargs => cmdargs
        info "cmd: #{cmd}".red
        xmllog = cmd.execute.join ''
        # info "xmllog: #{xmllog}".cyan
        SVNx::Log::Entries.new :xmllog => SVNx::Log::XMLEntries.new(xmllog)
      end

      # returns :added, :deleted, :changed 
      def status
        cmdargs = SVNx::StatusCommandArgs.new :path => @local
        cmd = SVNx::StatusCommand.new :cmdargs => cmdargs
        info "cmd: #{cmd}".red
        xml = cmd.execute.join ''

        info "xml: #{xml}".red

        entries = SVNx::Status::Entries.new :xmllog => SVNx::XMLStatus.new(xmllog)
        info "entries: #{entries}".bold
      end

      # def to_command subcmd, revcl, *args
      #   cmd = "svn #{subcmd}"
      #   info "cmd: #{cmd}".on_blue
      #   info "args: #{args}".on_blue
      #   args = args.flatten

      #   # revcl is [ -r, 3484 ]
      #   if revcl
      #     cmd << " " << revcl.join(" ")
      #   end
      #   cmd << " " << Util::quote_list(args)
      #   info "cmd: #{cmd}".on_blue
      #   cmd
      # end
      
      # def line_counts
      #   [ @svnelement && @svnelement.line_count, @fselement && @fselement.line_count ]
      # end

      def <=> other
        @svn <=> other.svn
      end

      def to_s
        "svn => " + @svn.to_s + "; local => " + @local.to_s
      end
    end
  end
end
