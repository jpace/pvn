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
      info "usepath: #{usepath}".color('#4aff4a')
      info = SVNx::InfoExec.new path: usepath, revision: revision
      info.entry
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
      svninfo = get_info

      filter = svninfo.url.dup
      filter.slice! svninfo.root

      # we can't cache this, because we don't know if there has been an svn
      # update since the previous run:
      logexec = SVNx::LogExec.new :path => @local, :revision => revision, :verbose => true, :use_cache => false
      entries = logexec.entries
      
      stat = status_to_symbol status

      matching = entries.collect do |entry|
        entry.paths.select do |epath|
          epath.action.send(stat) && epath.name.start_with?(filter)
        end
      end

      matching.flatten.uniq
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
      statexec = SVNx::StatusExec.new path: @local, use_cache: false
      entries = statexec.entries

      stat = status_to_symbol status
      info "stat: #{stat}".color('#fa33dd')

      entries.select do |entry|
        status.nil? || entry.status.send(stat)
      end
    end

    # returns log entries
    def logentries revision
      # use_cache should be conditional on revision:
      logexec = SVNx::LogExec.new :path => @local, :revision => revision.to_s, :verbose => true, :use_cache => false
      logexec.entries
    end
    
    def <=> other
      @svn <=> other.svn
    end

    def to_s
      "svn => " + @svn.to_s + "; local => " + @local.to_s
    end
  end
end
