#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/subcommands/diff/options'
require 'tempfile'
require 'pvn/subcommands/diff/differ'

module PVN::Subcommands::Diff
  class LocalDiffer < Differ
    def initialize options
      super
      
      paths = options.paths
      paths = %w{ . } if paths.empty?

      info "paths: #{paths}".yellow

      allentries = Array.new

      # we sort only the sub-entries, so the order in which paths were specified is preserved

      @whitespace = options.whitespace

      paths.each do |path|
        info "path: #{path}".red
        elmt = PVN::IO::Element.new :local => path
        entries = elmt.find_files_by_status
        
        allentries.concat entries.sort_by { |n| n.path }
      end

      info "allentries: #{allentries}"

      allentries.each do |entry|
        info "entry: #{entry.inspect}".on_blue
        case entry.status
        when 'modified'
          show_as_modified entry
        when 'deleted'
          show_as_deleted entry
        when 'added'
          show_as_added entry
        end
      end
    end

    ### $$$ todo: integrate these, from old diff/diffcmd
    def use_cache?
      super && !against_head?
    end

    def against_head?
      @options.change.value.nil? && @options.revision.head?
    end

    def read_working_copy entry
      pn = Pathname.new entry.path
      pn.readlines
    end

    def create_element entry
      PVN::IO::Element.new :local => entry.path
    end

    def cat elmt
      catargs = SVNx::CatCommandArgs.new :path => elmt.local, :use_cache => false
      cmd = SVNx::CatCommand.new catargs
      cmd.execute
    end

    def show_as_added entry
      fromlines = nil
      tolines = read_working_copy entry

      run_diff entry.path, fromlines, 0, tolines, 0
    end

    def show_as_deleted entry
      elmt = create_element entry

      svninfo = elmt.get_info
      lines = cat elmt

      run_diff entry.path, lines, svninfo.revision, nil, nil
    end
    
    def show_as_modified entry
      elmt = create_element entry

      svninfo = elmt.get_info
      remotelines = cat elmt

      fromrev = svninfo.revision
      torev = nil               # AKA working copy

      wclines = read_working_copy entry

      run_diff entry.path, remotelines, fromrev, wclines, torev
    end
  end
end
