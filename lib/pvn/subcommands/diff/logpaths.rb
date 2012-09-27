#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/subcommands/diff/paths'
require 'pvn/subcommands/diff/logpath'

module PVN::Subcommands::Diff
  # represents the log entries from one revision through another.
  class LogPaths < Paths
    include Loggable

    def initialize revision, paths
      super
    end

    def add_for_path path
      pathelmt = PVN::IO::Element.new :local => path
      pathinfo = pathelmt.get_info
      elmt = PVN::IO::Element.new :local => path
      logentries = elmt.logentries @revision

      logentries.each do |logentry|
        logentry.paths.each do |logentrypath|
          next if logentrypath.kind != 'file'
          add_log_entry_path logentry, logentrypath, pathinfo
        end 
      end
    end

    def add_log_entry_path logentry, logentrypath, pathinfo
      name = logentrypath.name
      revision = logentry.revision
      action = logentrypath.action
      url = pathinfo.url
      
      logpath = @elements.detect { |element| element.name == name }
      if logpath
        logpath.revisions << logentry.revision
      else
        @elements << LogPath.new(name, logentry.revision, action, url)
      end
    end
  end
end
