#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/diff/log_paths'
require 'pvn/diff/status_paths'
require 'pvn/diff/local_path'
require 'svnx/revision/range'
require 'logue/loggable'

module PVN::Diff
  # represents both LogPaths and StatusPaths
  class ChangedPaths
    include Logue::Loggable

    def initialize paths
      @paths = paths
    end

    def diff_revision_to_working_copy revision, whitespace
      # fromrev = revision.from.value

      info "revision: #{revision}".color(:cyan)
      rev = SVNx::Revision::Range.new revision.to_s, 'HEAD'
      info "rev: #{rev}".color(:cyan)

      logpaths = LogPaths.new rev, @paths
      info "logpaths: #{logpaths}"
      name_to_logpath = logpaths.to_map
      info "name_to_logpath: #{name_to_logpath}".color('#33fa33')

      statuspaths = StatusPaths.new revision, @paths
      name_to_statuspath = statuspaths.to_map

      @paths

      ### $$$ log names and status names should have a Name class

      names = Set.new
      names.merge name_to_logpath.keys.collect { |name| name[1 .. -1] }
      info "names: #{names.inspect}"

      info "name_to_statuspath: #{name_to_statuspath}".color('#ffcc33')
      name_to_statuspath.each do |name, stpath|
        info "name: #{name}".color('#fa33ff')
        info "stpath: #{stpath}".color('#fa33ff')
      end

      names.merge name_to_statuspath.keys
      info "names: #{names.inspect}"

      names.sort.each do |name|
        info "name: #{name}".color('#fa33ff')

        ### $$$ silliness because I don't have Diff::Name integrated:
        logname = '/' + name
        puts "logname: #{logname}"
        
        logpath = name_to_logpath[logname]
        info "logpath: #{logpath}"

        stpath = name_to_statuspath[name]
        info "stpath: #{stpath}"

        # frrev = nil

        if logpath
          # chgrevs = logpath.revisions_later_than fromrev
          logpath.diff_revision_to_working_copy revision, whitespace
        else
          # it's a local file only
          stpath.show_diff whitespace
        end
      end
    end
  end
end
