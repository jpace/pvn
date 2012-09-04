#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/base/util'

require 'svnx/log/command'
require 'svnx/log/entries'

require 'svnx/status/command'
require 'svnx/status/entries'

require 'svnx/info/command'
require 'svnx/info/entries'

require 'pvn/io/fselement'

module PVN; module IO; end; end

module PVN::IO
  # An element unites an svn element and a file/directory (at least one of
  # which should exist).

  class Element
    include Loggable

    attr_reader :svn
    attr_reader :local
    
    def initialize args = Hash.new
      info "args: #{args}"
      
      svnurl = args[:svnurl]
      fname  = args[:filename] || args[:file] # legacy
      # $$$ todo: map svnurl to SVNElement, and fname to FSElement

      @svn   = args[:svn] || (args[:file] && SVNElement.new(:filename => args[:file]))
      @local = PVN::FSElement.new args[:local] || args[:file]
      
      info "local: #{@local}"
    end

    def exist?
      @local && @local.exist?
    end

    def directory?
      if exist?
        @local.directory?
      else
        # look it up with svn info
        false
      end
    end

    def file?
      if exist?
        @local.file?
      else
        raise "need this"
      end
    end

    def get_info
      cmdargs = SVNx::InfoCommandArgs.new :path => @local
      infcmd  = SVNx::InfoCommand.new cmdargs
      output  = infcmd.execute
      
      infentries = SVNx::Info::Entries.new :xmllines => output
      infentries[0]
    end

    def repo_root
      get_info.root
    end

    # returns a set of entries modified over the given revision
    def find_modified_entries revision
      cmdargs = Hash.new

      cmdargs[:path] = @local

      info "cmdargs[:revision]: #{cmdargs[:revision]}"
      
      # we can't cache this, because we don't know if there has been an svn
      # update since the previous run:
      cmdargs[:use_cache] = false
      cmdargs[:limit] = nil
      cmdargs[:verbose] = true
      cmdargs[:revision] = revision

      logargs = SVNx::LogCommandArgs.new cmdargs
      entries = log(logargs).entries

      modified = Set.new

      info "entries: #{entries}"
      entries.each do |entry|
        info "entry: #{entry}".on_blue
        info entry.paths
        entry.paths.each do |epath|
          modified << epath if epath.action == 'M'
        end
      end

      modified
    end

    # returns a set of local files that are in modified status
    def find_modified_files
      cmdargs = SVNx::StatusCommandArgs.new :path => @local, :use_cache => false

      cmd = SVNx::StatusCommand.new cmdargs
      xml = cmd.execute
      entries = SVNx::Status::Entries.new :xmllines => xml

      modified = Set.new
      entries.each do |entry|
        modified << entry if entry.status == 'modified'
      end
      modified
    end

    # returns log entries
    def log cmdargs = SVNx::LogCommandArgs.new
      # $$$ todo: this should be either @local if set, otherwise @svn (url)
      # cmdargs.path = @local
      cmd = SVNx::LogCommand.new cmdargs
      SVNx::Log::Entries.new :xmllines => cmd.execute
    end

    # returns :added, :deleted, "modified"
    def status
      cmdargs = SVNx::StatusCommandArgs.new :path => @local
      cmd = SVNx::StatusCommand.new :cmdargs => cmdargs
      xml = cmd.execute.join ''
      entries = SVNx::Status::Entries.new :xml => SVNx::Status::XMLEntries.new(xml)
      entry = entries[0]
      entry.status
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
