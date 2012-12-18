#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/diff/options'
require 'pvn/diff/differ'
require 'pvn/diff/log_paths'
require 'pvn/diff/status_paths'
require 'pvn/diff/changed_paths'
require 'riel/log/loggable'

module PVN::Diff
  class RepositoryDiffer < Differ
    include RIEL::Loggable

    attr_reader :whitespace
    attr_reader :revision
    
    def initialize options
      super
      
      paths = options.paths
      paths = %w{ . } if paths.empty?

      # we sort only the sub-entries, so the order in which paths were specified is preserved

      rev = options.revision
      change = options.change

      # this is for getting revisions only later than the given revision
      # (argument); this only handling revision numbers (not dates) for now.

      rev = change ? [ change.to_i - 1, change.to_i ] : options.revision
      info "rev: #{rev}"
      @revision = PVN::Revision::Range.new(*rev)
      info "@revision: #{@revision}"

      # this indicates that this should be split into two classes:
      if @revision.working_copy?
        chgpaths = ChangedPaths.new paths
        chgpaths.diff_revision_to_working_copy @revision, @whitespace
      else
        logpaths = LogPaths.new @revision, paths
        logpaths.diff_revision_to_revision @revision, @whitespace
      end
    end
  end
end
