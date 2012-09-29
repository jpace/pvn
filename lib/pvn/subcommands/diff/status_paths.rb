#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/subcommands/diff/path'
require 'pvn/subcommands/diff/paths'

module PVN::Subcommands::Diff
  # represents the log entries from one revision through another.
  class StatusPaths < Paths
    include Loggable

    def add_for_path path
      pathelmt = PVN::IO::Element.new :local => path
      pathinfo = pathelmt.get_info
      elmt = PVN::IO::Element.new :local => path
      add elmt, pathinfo.url
    end

    def add elmt, url
      status = elmt.find_files_by_status
      info "status: #{status}"
      status.entries.each do |entry|
        # we don't care about unversioned entries for diffing.
        next if entry.status == 'unversioned'
        
        info "@revision: #{@revision}".red
        info "entry: #{entry}".red
        # svn log prepends /; svn status does not
        name = '/' + entry.path
        info "name: #{name}"
        rev = :working_copy
        info "rev: #{rev}"

        # what Status::Entry calls a status, we call an action, unifying it with
        # svn log representation.
        action = entry.status
        info "action: #{action}"
        revisions = get_status_revisions entry
        info "revisions: #{revisions}".on_cyan

        info "status.revision: #{entry.status_revision}".red

        @elements << Path.new(name, entry.status_revision, action, url)
      end
    end

    # this may belong in Status::Entry
    def get_status_revisions status_entry
      # the printing revision in svn (svn diff -r20) are confusing, but this
      # is what it looks like:

      # when a file is added locally
      #     the revisions are (0, 0)
      # when a file is modified:
      #     if the file is modified in other revisions since givenfromrev
      #         the revision is (most recent rev, working copy)
      #     otherwise
      #         the revision is (previous revision, working copy)
      # when a file is deleted:
      #     the revision is (given from rev, working copy)

      # okay, summary #2:

      # if a file is modified,
      #     if the file existed at fromrev
      #         it is compared with fromrev
      #     else
      #         it is compared to BASE

      info "status_entry.status: #{status_entry.status}".yellow

      action = SVNx::Action.new status_entry.status
      case
      when action.added?
        info "added"
        [ 0, 0 ]
      when action.deleted?
        info "deleted"
        [ @revision.from, :working_copy ]
      when action.modified?
        info "modified"
        [ status_entry.status_revision, :working_copy ]
      end
    end    
  end
end
