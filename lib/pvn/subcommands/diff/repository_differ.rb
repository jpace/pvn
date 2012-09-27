#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/subcommands/diff/options'
require 'pvn/subcommands/diff/differ'
require 'pvn/subcommands/diff/logpaths'
require 'pvn/subcommands/diff/status_paths'
require 'pvn/subcommands/diff/revision'
require 'pp'

module PVN::Subcommands::Diff
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

      @revision = RevisionRange.new change, rev
      info "@revision: #{@revision}"

      logpaths = LogPaths.new @revision, paths

      name_to_logpath = logpaths.to_map

      name_to_logpath.sort.each do |name, logpath|
        diff_logpath logpath
      end

      if @revision.working_copy?
        statuspaths = StatusPaths.new @revision, paths
        info "statuspaths: #{statuspaths}".blue
        # name_to_logpath = logpaths.to_map
      end        
    end

    def show_as_modified elmt, path, fromrev, torev
      fromlines = elmt.cat fromrev
      tolines = elmt.cat torev
      fromrev = @revision.from.value.to_i - 1
      run_diff path, fromlines, fromrev, tolines, @revision.to
    end

    def show_as_added elmt, path
      info "elmt: #{elmt}".on_blue
      tolines = elmt.cat @revision.to
      run_diff path, nil, 0, tolines, @revision.to
    end

    def show_as_deleted elmt, path
      fromrev = @revision.from.value.to_i - 1
      fromlines = elmt.cat fromrev
      run_diff path, fromlines, fromrev, nil, @revision.to
    end
    
    def diff_logpath logpath
      info "logpath.name: #{logpath.name}"
      info "logpath: #{logpath.inspect}"
      name = logpath.name

      revisions = logpath.revisions
      info "revisions: #{revisions}"
      
      # all the paths will be the same, so any can be selected (actually, a
      # logpath should have multiple revisions)
      svnurl = logpath.url
      info "svnurl: #{svnurl}"
      
      svnpath = svnurl + name
      info "svnpath: #{svnpath}"
      elmt = PVN::IO::Element.new :svn => svnpath

      displaypath = name[1 .. -1]
      info "displaypath: #{displaypath}"

      firstrev = revisions[0]
      lastrev = revisions[-1]

      action = logpath.action

      # we ignore unversioned logpaths
      
      case
      when action.added?
        show_as_added elmt, displaypath
      when action.deleted?
        show_as_deleted elmt, displaypath
      when action.modified?
        lastrev = revisions[-1]
        fromrev, torev = if firstrev == lastrev
                           [ @revision.from.value.to_i - 1, @revision.to ]
                         else
                           [ firstrev.to_i - 1, lastrev ]
                         end
        show_as_modified elmt, displaypath, fromrev, torev
      end
    end
  end
end
