#!/usr/bin/ruby -w
# -*- ruby -*-

module PVN::Subcommands::Diff
  # an entry with a name, revision, logentry.path, and svninfo
  class LogPath
    attr_reader :name
    attr_reader :revisions
    attr_reader :logentrypath
    attr_reader :svninfo
    
    def initialize name, revision, logentrypath, svninfo
      @name = name
      @revisions = [ revision ]
      @logentrypath = logentrypath
      @svninfo = svninfo
    end

    def to_s
      inspect
    end
  end
end
