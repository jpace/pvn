#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/diff/options'
require 'pvn/diff/differ'
require 'pvn/diff/log_paths'
require 'pvn/diff/status_paths'
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
        diff_revision_to_working_copy paths
      else
        logpaths = LogPaths.new @revision, paths
        logpaths.diff_revision_to_revision @fromrev, @revision, @whitespace
      end
    end

    def diff_revision_to_working_copy paths
      rev = PVN::Diff::RevisionRange.new nil, [ @revision.to_s, 'HEAD' ]
      logpaths = LogPaths.new rev, paths
      name_to_logpath = logpaths.to_map

      changed_paths = Hash.new { |h, k| h[k] = Array.new }

      name_to_logpath.sort.each do |name, logpath|
        info "name: #{name}"
        info "logpath: #{logpath}".cyan
        if logpath.is_revision_later_than? @fromrev
          info "name: #{name}".bold.green
          info "logpath: #{logpath}".green
          changed_paths[name] << logpath
        end
      end

      # info "changed_paths: #{changed_paths}".blue

      statuspaths = StatusPaths.new @revision, paths
      name_to_statuspath = statuspaths.to_map

      name_to_statuspath.each do |name, statuspath|
        changed_paths[name] << statuspath
      end

      changed_paths.sort.each do |name, paths|
        info "name: #{name}".bold.yellow
        paths.each do |path|
          info "path: #{path}".yellow
        end
        # diff_paths paths
      end
    end

    def diff_status_path statuspath, logpath
    end
  end
end
