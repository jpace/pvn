#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/diff/path'

module PVN::Diff
  class LocalPath < Path
    # that's a Status::Entry
    def initialize entry
      @entry = entry
      @elmt = PVN::IO::Element.new :local => @entry.path
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

    def read_working_copy
      pn = Pathname.new @entry.path
      pn.readlines
    end

    def get_latest_revision
      svninfo = @elmt.get_info
      svninfo.revision
    end

    def get_remote_lines
      # revision = nil; use_cache = false
      @elmt.cat nil, false
    end

    def run_diff from_lines, from_rev, to_lines, to_rev, whitespace
      super @entry.path, from_lines, from_rev, to_lines, to_rev, whitespace
    end

    def show_as_added
      run_diff nil, 0, read_working_copy, 0, nil
    end

    def show_as_deleted
      fromrev = changes[0].revision
      run_diff get_remote_lines, fromrev, nil, nil, nil
    end
    
    def show_as_modified whitespace
      fromrev = changes[0].revision
      run_diff get_remote_lines, fromrev, read_working_copy, nil, whitespace
    end
  end
end
