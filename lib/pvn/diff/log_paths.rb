#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/diff/paths'
require 'pvn/diff/log_path'

module PVN::Diff
  # represents the log entries from one revision through another.
  class LogPaths < Paths
    include Loggable

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
      name = logentrypath.name
      revision = logentry.revision
      action = logentrypath.action
      url = pathinfo.url

      info "action: #{action}"
      
      path = @elements.detect { |element| element.name == name }
      if path
        info "path: #{path}"
        path.add_change logentry.revision, action
      else
        path = LogPath.new(name, logentry.revision, action, url)
        info "path: #{path}"
        @elements << path
      end
    end

    def diff_revision_to_revision fromrev, revision, whitespace
      name_to_logpath = to_map

      name_to_logpath.sort.each do |name, logpath|
        if logpath.is_revision_later_than? fromrev
          logpath.diff revision, whitespace
        end
      end
    end
  end
end
