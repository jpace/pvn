#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/diff/paths'
require 'pvn/diff/log_path'
require 'logue/loggable'

module PVN::Diff
  # represents the log entries from one revision through another.
  class LogPaths < Paths
    include Logue::Loggable

    def add_for_path path
      pathelmt = PVN::IO::Element.new :local => path
      pathinfo = pathelmt.get_info
      elmt = PVN::IO::Element.new :local => path
      logentries = elmt.logentries @revision

      logentries.each do |logentry|
        logentry.paths.each do |logentrypath|
          next if logentrypath.kind != 'file'
          add_path logentry, logentrypath, pathinfo
        end 
      end
    end

    def add_path logentry, logentrypath, pathinfo
      info "logentry: #{logentry}".color('#fa3d3d')

      name = logentrypath.name
      revision = logentry.revision
      action = logentrypath.action
      info "action: #{action}"
      url = pathinfo.url

      info "action: #{action}".color('#fa3d3d')
      info "url: #{url}"
      
      path = @elements.detect { |element| element.name == name }
      if path
        info "path: #{path}"
        path.add_change revision, action
      else
        path = LogPath.new(name, revision, action, url)
        info "path: #{path}"
        @elements << path
      end
    end

    def diff_revision_to_revision revision, whitespace
      name_to_logpath = to_map

      name_to_logpath.sort.each do |name, logpath|
        if logpath.is_revision_later_than? revision.from.value
          logpath.diff_revision_to_revision revision, whitespace
        end
      end
    end
  end
end
