#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/diff/log_paths'
require 'pvn/diff/status_paths'
require 'pvn/diff/revision'
require 'pvn/diff/local_path'
require 'pp'

module PVN::Diff
  # represents both LogPaths and StatusPaths
  class ChangedPaths
    include Loggable

    def initialize paths
      @paths = paths
    end

    def diff_revision_to_working_copy fromrev, revision, whitespace
      info "revision: #{revision}".cyan
      rev = PVN::Diff::RevisionRange.new nil, [ revision.to_s, 'HEAD' ]
      info "rev: #{rev}".cyan

      logpaths = LogPaths.new rev, @paths
      name_to_logpath = logpaths.to_map

      statuspaths = StatusPaths.new revision, @paths
      name_to_statuspath = statuspaths.to_map

      # log names and status names should have a Name class

      names = Set.new
      names.merge name_to_logpath.keys.collect { |name| name[1 .. -1] }
      info "names: #{names.inspect}"

      names.merge name_to_statuspath.keys
      info "names: #{names.inspect}"

      names.sort.each do |name|
        info "name: #{name}"

        ### $$$ silliness because I don't have Diff::Name integrated:
        logname = '/' + name
        
        logpath = name_to_logpath[logname]
        info "logpaths: #{logpaths}"

        stpath = name_to_statuspath[name]
        info "stpath: #{stpath}"

        frrev = nil

        if logpath
          chgrevs = logpath.revisions_later_than fromrev
          diff_logpath logpath, fromrev, revision, whitespace
        else
          # it's a local file only
          stpath.show_diff whitespace
        end
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
        info "change: #{change}"
        return revision.from.value
      else
        nil
      end
    end

    def diff_logpath logpath, fromrev, revision, whitespace
      # return unless logpath.name.index 'rubies.zip'

      info "logpath: #{logpath}"

      change = logpath.revisions_later_than(fromrev).first
      info "change: #{change}".red

      # revision should be a class here, not a primitive
      diffrev = get_diff_revision change, revision
      
      display_path = logpath.get_display_path

      pn = Pathname.new display_path

      svnpath = logpath.url + logpath.name
      info "svnpath: #{svnpath}"
      elmt = PVN::IO::Element.new :svn => svnpath

      case
      when change.action.added?
        logpath.show_as_added elmt, display_path, revision, whitespace
        return
      end
      
      fromlines = elmt.cat diffrev
      info "fromlines.size: #{fromlines.size}"
      pp fromlines

      tolines = pn.read
      info "tolines.size: #{tolines.size}"
      pp tolines

      fromrev = revision.from.value.to_i
      logpath.run_diff display_path, fromlines, diffrev, tolines, nil, whitespace
    end
      
    def diff_paths paths
    end
  end
end
