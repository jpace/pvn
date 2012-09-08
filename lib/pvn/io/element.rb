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
      @local = args[:local] && PVN::FSElement.new(args[:local] || args[:file])
      @path  = args[:path]
      
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

    def get_info revision = nil
      usepath = @local || @path
      info "usepath: #{usepath}"
      cmdargs = SVNx::InfoCommandArgs.new :path => usepath, :revision => revision
      infcmd  = SVNx::InfoCommand.new cmdargs
      output  = infcmd.execute
      
      infentries = SVNx::Info::Entries.new :xmllines => output
      infentries[0]
    end

    def repo_root
      get_info.root
    end

    def has_revision? rev
      usepath = @local || @path
      info "usepath: #{usepath}"

      # was there a revision then?
      begin
        svninfo = get_info rev
        true
      rescue => e
        # skip it
        false
      end
    end

    # returns a set of entries modified over the given revision
    def find_modified_entries revision
      cmdargs = Hash.new

      svninfo = get_info
      info "svninfo: #{svninfo}".red
      info "svninfo.url: #{svninfo.url}".red
      info "svninfo.root: #{svninfo.root}".red

      filter = svninfo.url.dup
      filter.slice! svninfo.root
      info "filter: #{filter}"

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

      # info "entries: #{entries}"
      entries.each do |entry|
        info "entry: #{entry.class}"
        # info entry.paths
        entry.paths.each do |epath|
          if epath.action == 'M' && epath.name.start_with?(filter)
            info "epath: #{epath}".yellow
            modified << epath
          end
        end
      end

      modified
    end

    # returns a set of local files that are in the given status
    def find_files
      cmdargs = SVNx::StatusCommandArgs.new :path => @local, :use_cache => false

      cmd = SVNx::StatusCommand.new cmdargs
      xml = cmd.execute
      SVNx::Status::Entries.new :xmllines => xml
    end

    # returns a set of local files that are in the given status
    def find_files_by_status status
      entries = find_files

      entries.select do |entry|
        entry.status == status
      end
    end

    # returns a set of local files that are in modified status
    def find_modified_files
      find_files_by_status 'modified'
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
