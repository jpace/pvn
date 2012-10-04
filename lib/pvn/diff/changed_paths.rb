#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/diff/log_paths'
require 'pvn/diff/status_paths'
require 'pvn/diff/revision'

module PVN::Diff
  # represents both LogPaths and StatusPaths
  class ChangedPaths
    include Loggable

    def initialize paths
      @paths = paths
    end

    def diff_revision_to_working_copy fromrev, revision, whitespace
      rev = PVN::Diff::RevisionRange.new nil, [ revision.to_s, 'HEAD' ]
      logpaths = LogPaths.new rev, @paths
      name_to_logpath = logpaths.to_map

      changed_paths = Hash.new { |h, k| h[k] = Array.new }

      name_to_logpath.sort.each do |name, logpath|
        info "name: #{name}"
        info "logpath: #{logpath}".cyan
        if logpath.is_revision_later_than? fromrev
          info "name: #{name}".bold.green
          info "logpath: #{logpath}".green
          changed_paths[name] << logpath
        end
      end

      # info "changed_paths: #{changed_paths}".blue

      statuspaths = StatusPaths.new revision, @paths
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

    def diff_paths paths
    end
  end
end
