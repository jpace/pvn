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
      fromlines = elmt.cat fromrev
      tolines = elmt.cat torev
      fromrev = revision.from.value.to_i
      run_diff path, fromlines, fromrev, tolines, revision.to, whitespace
    end

    def show_as_added elmt, path, revision, whitespace
      tolines = elmt.cat revision.to
      run_diff path, nil, 0, tolines, revision.to, whitespace
    end

    def show_as_deleted elmt, path, revision, whitespace
      fromrev = revision.from.value.to_i
      fromlines = elmt.cat fromrev
      run_diff path, fromlines, fromrev, nil, revision.to, whitespace
    end
    
    # log entries have names of the form /foo/bar.rb, relative to the URL.
    def get_display_path
      name[1 .. -1]
    end

    def diff revision, whitespace
      logpath = self
      info "name: #{name}"

      allchanges = changes
      
      # all the paths will be the same, so any can be selected (actually, a
      # logpath should have multiple changes)
      svnpath = url + name
      info "svnpath: #{svnpath}"
      elmt = PVN::IO::Element.new :svn => svnpath

      displaypath = get_display_path

      info "revision.from: #{revision.from}".cyan

      rev_change = changes.detect do |chg| 
        revarg = PVN::Revision::Argument.new chg.revision
        revarg > revision.from
      end

      info "rev_change: #{rev_change}".green

      # we ignore unversioned logpaths
      
      # I'm sure there is a bunch of permutations here, so this is probably
      # overly simplistic.
      action = rev_change.action
      
      case
      when action.added?
        show_as_added elmt, displaypath, revision, whitespace
      when action.deleted?
        show_as_deleted elmt, displaypath, revision, whitespace
      when action.modified?
        firstrev = allchanges[0].revision
        lastrev = allchanges[-1].revision
        fromrev, torev = if firstrev == lastrev
                           [ revision.from.value.to_i - 1, revision.to ]
                         else
                           [ firstrev.to_i - 1, lastrev ]
                         end
        show_as_modified elmt, displaypath, firstrev, torev, revision, whitespace
      end
    end

    def is_revision_later_than? revision
      changes.detect do |chg|
        info "chg: #{chg.revision.inspect}"
        x = PVN::Revision::Argument.new chg.revision
        y = PVN::Revision::Argument.new revision
        x > y
      end
    end
  end
end
