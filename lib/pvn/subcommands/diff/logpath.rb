#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/action'

module PVN::Subcommands::Diff
  # an entry with a name, revision, logentry.path, and svninfo
  class LogPath
    attr_reader :name
    attr_reader :revisions
    attr_reader :action
    attr_reader :url
    
    # that's the root url:
    def initialize name, revision, action, url
      @name = name
      @revisions = [ revision ]
      @action = action.kind_of?(SVNx::Action) || SVNx::Action.new(action)
      @url = url
    end

    def to_s
      inspect
    end
  end
end
