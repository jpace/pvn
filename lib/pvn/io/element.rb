#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'logue/loggable'
require 'svnx/log/entries'
require 'svnx/status/entries'
require 'svnx/status/command'
require 'svnx/info/entries'
require 'svnx/info/command'
require 'svnx/cat/command'
require 'pvn/io/fselement'
require 'svnx/io/element'

module PVN; module IO; end; end

module PVN::IO
  # An element unites an svn element and a file/directory (at least one of
  # which should exist).

  class Element
    include Logue::Loggable

    attr_reader :svn
    attr_reader :local
    
    def initialize args = Hash.new
      info "args: #{args.inspect}".color("438802")
      
      # svnurl = args[:svnurl]
      # fname  = args[:filename] || args[:file] # legacy
      # $$$ todo: map svnurl to SVNElement, and fname to FSElement

      @svn   = args[:svn] || (args[:file] && SVNElement.new(:filename => args[:file]))
      @local = args[:local] && PVN::FSElement.new(args[:local] || args[:file])
      @path  = args[:path]
      
      info "local: #{@local.inspect}"

      @svnelement = SVNx::IO::Element.new args
      info "@svnelement: #{@svnelement}"
    end

    def exist?
      @local && @local.exist?
    end

    def directory?
      @svnelement.directory?
    end

    def file?
      @svnelement.file?
    end

    def get_info revision = nil
      usepath = @local || @path
      inf = SVNx::InfoExec.new path: usepath, revision: revision
      inf.entry
    end

    def repo_root
      get_info.root
    end

    def has_revision? rev
      # was there a revision then?
      begin
        get_info rev
        true
      rescue => e
        puts "e: #{e}"
        raise e
        # false
      end
    end

    def status_to_symbol status
      # add a ? if not there already
      (status.to_s.sub(%r{\??$}, '?')).to_sym
    end

    # returns a set of entries matching status for the given revision
    def find_entries revision, status
      @svnelement.find_in_log revision, status
    end

    def cat revision, use_cache = false
      info "@local: #{@local}"
      info "@path: #{@path}"
      info "@svn: #{@svn}"
      
      path = (@local || @path || @svn).dup
      info "path: #{path.to_s}"
      if revision && revision != :working_copy
        path << '@' << revision.to_s
      end
      info "path: #{path}"
      catexec = SVNx::CatExec.new path: path, revision: nil, use_cache: use_cache
      catexec.output
    end

    # returns a set of local files that have the given status/action
    def find_files_by_status status = nil
      @svnelement.find_by_status status
    end

    # returns log entries
    def logentries revision
      @svnelement.log_entries :revision => revision
    end
    
    def <=> other
      @svn <=> other.svn
    end

    def to_s
      "svn => " + @svn.to_s + "; local => " + @local.to_s
    end
  end
end
