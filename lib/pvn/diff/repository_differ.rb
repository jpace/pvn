#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/diff/options'
require 'pvn/diff/differ'
require 'pvn/diff/log_paths'
require 'pvn/diff/status_paths'
require 'pvn/diff/changed_paths'
require 'pvn/diff/revision'

module PVN::Diff
  class RepositoryDiffer < Differ
    include Loggable

    attr_reader :whitespace
    attr_reader :revision
    
    def initialize options
      paths = options.paths
      paths = %w{ . } if paths.empty?

      # we sort only the sub-entries, so the order in which paths were specified is preserved

      @whitespace = options.whitespace
      rev = options.revision
      change = options.change

      if rev[1].nil? || rev[1].to == :working_copy
        # rev[1] = "BASE"
      end

      # this is for getting revisions only later than the given revision
      # (argument); this only handling revision numbers (not dates) for now.

      @fromrev = if change 
                   change.to_i - 1
                 else
                   rev[0].to_i
                 end

      @revision = RevisionRange.new change, rev

      # this indicates that this should be split into two classes:
      if @revision.working_copy?
        chgpaths = ChangedPaths.new paths
        chgpaths.diff_revision_to_working_copy @fromrev, @revision, @whitespace
      else
        logpaths = LogPaths.new @revision, paths
        logpaths.diff_revision_to_revision @fromrev, @revision, @whitespace
      end
    end
  end
end
