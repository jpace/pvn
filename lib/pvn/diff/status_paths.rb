#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/diff/path'
require 'pvn/diff/paths'
require 'logue/loggable'
require 'pvn/diff/local_path'

module PVN::Diff
  class StatusPaths < Paths
    include Logue::Loggable

    def add_for_path path
      pathelmt = PVN::IO::Element.new :local => path
      pathinfo = pathelmt.get_info
      elmt = PVN::IO::Element.new :local => path
      add elmt, pathinfo.url
    end

    def add elmt, url
      status = elmt.find_files_by_status
      info "status: #{status}".color('#33facc')
      status.entries.each do |entry|
        info "entry: #{entry}".color('#33facc')
        # we don't care about unversioned entries for diffing.
        info "entry.status: #{entry.status}".color('#33facc')
        info "entry.status.class: #{entry.status.class}".color('#33facc')
        next if entry.status.unversioned?
        
        # svn log prepends /; svn status does not
        # name = '/' + entry.path
        # rev = :working_copy

        # what Status::Entry calls a status, we call an action, unifying it with
        # svn log representation.
        # action = entry.status

        info "entry.status_revision: #{entry.status_revision}"
        path = LocalPath.new entry
        @elements << path
      end
    end
    
    ### $$$ this may belong in Status::Entry
    def get_status_revisions status_entry
      # the printing revision in svn (svn diff -r20) are confusing, but this
      # is what it looks like:

      # if a file is modified,
      #     if the file existed at fromrev
      #         it is compared with fromrev
      #     else
      #         it is compared to BASE

      info "status_entry.status: #{status_entry.status}".color('#2c2cdd')

      action = SVNx::Action.new status_entry.status
      info "action: #{action}".color('#2c2cdd')
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
