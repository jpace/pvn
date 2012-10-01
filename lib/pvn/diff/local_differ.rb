#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/diff/options'
require 'pvn/diff/differ'

module PVN::Diff
  class LocalDiffer < Differ
    def initialize options
      super
      
      paths = options.paths
      paths = %w{ . } if paths.empty?

      allentries = Array.new

      # we sort only the sub-entries, so the order in which paths were specified
      # is preserved

      @whitespace = options.whitespace

      paths.each do |path|
        elmt = PVN::IO::Element.new :local => path
        entries = elmt.find_files_by_status
        allentries.concat entries.sort_by { |n| n.path }
      end

      allentries.each do |entry|
        show_entry entry
      end
    end

    def show_entry entry
      info "entry: #{entry.inspect}"
      case entry.status
      when 'modified'
        show_as_modified entry
      when 'deleted'
        show_as_deleted entry
      when 'added'
        show_as_added entry
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
      elmt = PVN::IO::Element.new :local => elmt.local
      elmt.cat nil, :use_cache => false
    end

    def show_as_added entry
      fromlines = nil
      tolines = read_working_copy entry

      run_diff entry.path, fromlines, 0, tolines, 0
    end

    def get_latest_revision elmt
      svninfo = elmt.get_info
      svninfo.revision
    end

    def show_as_deleted entry
      elmt = create_element entry

      fromrev = get_latest_revision elmt
      lines = cat elmt

      run_diff entry.path, lines, fromrev, nil, nil
    end
    
    def show_as_modified entry
      elmt = create_element entry
      remotelines = cat elmt
      fromrev = get_latest_revision elmt
      wclines = read_working_copy entry
      run_diff entry.path, remotelines, fromrev, wclines, nil
    end
  end
end
