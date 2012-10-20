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
      info "path: #{path}".on_blue
      tolines = elmt.cat revision.to
      info "tolines: #{tolines}".blue
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

    def diff_revision_to_revision revision, whitespace
      logpath = self
      info "name: #{name}"

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
        firstrev = changes[0].revision
        lastrev = changes[-1].revision
        fromrev, torev = if firstrev == lastrev
                           [ revision.from.value.to_i - 1, revision.to ]
                         else
                           [ firstrev.to_i - 1, lastrev ]
                         end
        show_as_modified elmt, displaypath, firstrev, torev, revision, whitespace
      end
    end

    def get_diff_revision change, revision
      info "change: #{change}"
      info "revision: #{revision}"
      # find the first revision where logpath was in svn, no earlier than the
      # revision.from value
      if change.action.added?
        return change.revision.to_i
      elsif change.revision.to_i >= revision.from.value
        return revision.from.value
      else
        nil
      end
    end

    def diff_revision_to_working_copy revision, whitespace
      fromrev = revision.from.value.to_i

      ### $$$ this doesn't handle the case where a file has been added, then
      ### modified.

      change = revisions_later_than(fromrev).first
      info "change: #{change}".red

      # revision should be a class here, not a primitive
      diffrev = get_diff_revision change, revision
      
      display_path = get_display_path

      pn = Pathname.new display_path

      svnpath = url + name
      info "svnpath: #{svnpath}"
      elmt = PVN::IO::Element.new :svn => svnpath

      if change.action.added?
        show_as_added elmt, display_path, revision, whitespace
      else
        fromlines = elmt.cat diffrev
        info "fromlines.size: #{fromlines.size}"
        pp fromlines

        tolines = pn.readlines
        info "tolines.size: #{tolines.size}"
        pp tolines

        run_diff display_path, fromlines, diffrev, tolines, nil, whitespace
      end
    end

    def is_revision_later_than? revision
      revisions_later_than(revision).first
    end

    def revisions_later_than revision
      changes.select do |chg|
        info "chg: #{chg.revision.inspect}"
        x = PVN::Revision::Argument.new chg.revision
        y = PVN::Revision::Argument.new revision
        x > y
      end
    end
  end
end