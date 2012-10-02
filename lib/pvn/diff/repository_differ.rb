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
        diff_revision_to_revision paths
      end
    end

    def diff_revision_to_working_copy paths
      logpaths = LogPaths.new @revision, paths
      name_to_logpath = logpaths.to_map

      names = Set.new
      names.merge name_to_logpath.keys
      info "names: #{names.inspect}".red

      name_to_logpath.sort.each do |name, logpath|
        info "name: #{name}".cyan
        info "logpath: #{logpath}".cyan
        if is_revision_later_than? logpath, @fromrev
          info "logpath: #{logpath}".on_cyan
          # diff_logpath logpath
        end
      end

      statuspaths = StatusPaths.new @revision, paths
      info "statuspaths: #{statuspaths}".on_blue
      name_to_statuspath = statuspaths.to_map

      names.merge name_to_statuspath.keys
      info "names: #{names.inspect}".red

      names.sort.each do |name|
        info "name: #{name}".on_blue
        logpath = name_to_logpath[name]
        info "logpath: #{logpath}".blue
        statuspath = name_to_statuspath[name]
        info "statuspath: #{statuspath}".blue
        diff_status_path statuspath, logpath
      end
    end
    
    def diff_revision_to_revision paths
      logpaths = LogPaths.new @revision, paths
      name_to_logpath = logpaths.to_map

      name_to_logpath.sort.each do |name, logpath|
        if is_revision_later_than? logpath, @fromrev
          diff_logpath logpath
        end
      end
    end

    def is_revision_later_than? logpath, revision
      logpath.changes.detect do |chg|
        info "chg: #{chg.revision.inspect}".cyan
        x = PVN::Revision::Argument.new chg.revision
        y = PVN::Revision::Argument.new revision
        x > y
      end
    end

    # the "path" parameter is the displayed name; "logpath" is the LogPath.
    # These are in the process of refactoring.
    def show_as_modified elmt, path, fromrev, torev, logpath
      info "elmt: #{elmt}"
      fromlines = elmt.cat fromrev
      tolines = elmt.cat torev
      fromrev = @revision.from.value.to_i
      logpath.run_diff path, fromlines, fromrev, tolines, @revision.to, @whitespace
    end

    def show_as_added elmt, path, logpath
      info "elmt: #{elmt}"
      tolines = elmt.cat @revision.to
      logpath.run_diff path, nil, 0, tolines, @revision.to, @whitespace
    end

    def show_as_deleted elmt, path, logpath
      info "elmt: #{elmt}"
      fromrev = @revision.from.value.to_i
      fromlines = elmt.cat fromrev
      logpath.run_diff path, fromlines, fromrev, nil, @revision.to, @whitespace
    end

    def diff_status_path statuspath, logpath
    end
    
    def diff_logpath logpath
      info "logpath.name: #{logpath.name}"
      name = logpath.name

      allchanges = logpath.changes
      
      # all the paths will be the same, so any can be selected (actually, a
      # logpath should have multiple changes)
      svnurl = logpath.url
      info "svnurl: #{svnurl}"
      
      svnpath = svnurl + name
      info "svnpath: #{svnpath}"
      elmt = PVN::IO::Element.new :svn => svnpath

      displaypath = name[1 .. -1]
      info "displaypath: #{displaypath}"

      firstrev = allchanges[0].revision
      info "firstrev: #{firstrev}".yellow
      lastrev = allchanges[-1].revision

      info "@revision.from: #{@revision.from}".cyan

      changes = logpath.changes.select do |chg| 
        info "chg.revision: #{chg.revision.inspect}".cyan
        revarg = PVN::Revision::Argument.new chg.revision
        revarg > @revision.from
      end

      info "changes: #{changes}".green

      # we ignore unversioned logpaths
      
      # I'm sure there is a bunch of permutations here, so this is probably
      # overly simplistic.
      firstaction = changes[0].action
      
      case
      when firstaction.added?
        show_as_added elmt, displaypath, logpath
      when firstaction.deleted?
        show_as_deleted elmt, displaypath, logpath
      when firstaction.modified?
        fromrev, torev = if firstrev == lastrev
                           [ @revision.from.value.to_i - 1, @revision.to ]
                         else
                           [ firstrev.to_i - 1, lastrev ]
                         end
        info "firstrev: #{firstrev.inspect}"
        info "torev: #{torev.inspect}"
        show_as_modified elmt, displaypath, firstrev, torev, logpath
      end
    end
  end
end
