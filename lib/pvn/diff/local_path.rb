#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/diff/options'
require 'pvn/diff/path'

module PVN::Diff
  class LocalPath < Path
    # that's a Status::Entry
    def initialize entry
      @entry = entry
      @elmt = create_element
      name = entry.path
      action = SVNx::Action.new @entry.status
      revision = action.added? ? 0 : @elmt.get_info.revision
      super name, revision, action, nil
    end

    def show_diff whitespace = nil
      case @entry.status
      when 'modified'
        show_as_modified whitespace
      when 'deleted'
        show_as_deleted
      when 'added'
        show_as_added
      end
    end

    ### $$$ todo: integrate these, from old diff/diffcmd
    def use_cache?
      super && !against_head?
    end

    def against_head?
      @options.change.value.nil? && @options.revision.head?
    end

    def read_working_copy
      pn = Pathname.new @entry.path
      pn.readlines
    end

    def create_element
      PVN::IO::Element.new :local => @entry.path
    end

    def get_latest_revision
      svninfo = @elmt.get_info
      svninfo.revision
    end

    def show_as_added
      fromlines = nil
      tolines = read_working_copy
      run_diff @entry.path, fromlines, 0, tolines, 0, nil
    end

    def show_as_deleted
      fromrev = changes[0].revision
      # revision = nil; use_cache = false
      lines = @elmt.cat nil, false
      run_diff @entry.path, lines, fromrev, nil, nil, nil
    end
    
    def show_as_modified whitespace
      remotelines = @elmt.cat nil, false
      fromrev = changes[0].revision
      wclines = read_working_copy
      run_diff @entry.path, remotelines, fromrev, wclines, nil, whitespace
    end
  end
end
