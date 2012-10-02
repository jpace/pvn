#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/diff/path'

module PVN::Diff
  # this is a path wrapping a log entry; it could also be a RemotePath or a
  # RepoPath.
  class LogPath < Path
    
    # the "path" parameter is the displayed name; "logpath" is the LogPath.
    # These are in the process of refactoring.
    def show_as_modified elmt, path, fromrev, torev, revision, whitespace
      info "elmt: #{elmt}"
      fromlines = elmt.cat fromrev
      tolines = elmt.cat torev
      fromrev = revision.from.value.to_i
      run_diff path, fromlines, fromrev, tolines, revision.to, whitespace
    end

    def show_as_added elmt, path, revision, whitespace
      info "elmt: #{elmt}"
      tolines = elmt.cat revision.to
      run_diff path, nil, 0, tolines, revision.to, whitespace
    end

    def show_as_deleted elmt, path, revision, whitespace
      info "elmt: #{elmt}"
      fromrev = revision.from.value.to_i
      fromlines = elmt.cat fromrev
      run_diff path, fromlines, fromrev, nil, revision.to, whitespace
    end
  end
end
