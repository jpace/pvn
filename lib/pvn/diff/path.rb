#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/action'
require 'pvn/diff/path_revision'

module PVN; module Diff; end; end

module PVN::Diff
  class Path
    include Loggable
    
    attr_reader :name
    # attr_reader :revisions
    attr_reader :action
    attr_reader :url
    ### $$$ this will be renamed revisions, when the old one is gone.
    attr_reader :path_revisions
    
    # that's the root url
    def initialize name, revision, action, url
      @name = name
      @revisions = Array.new
      @path_revisions = Array.new
      add_revision revision, action
      @action = action.kind_of?(SVNx::Action) || SVNx::Action.new(action)
      @url = url
    end

    def add_revision rev, action
      info "rev: #{rev}".on_green
      if rev.kind_of?(Array)
        rev.each do |rv|
          @revisions << to_revision(rv)
        end
      else
        @revisions << to_revision(rev)
      end
      @path_revisions << PathRevision.new(to_revision(rev), action)
    end

    def to_revision rev
      # or should we convert this to Revision::Argument, and @revisions is
      # Revision::Range?
      rev.kind_of?(Fixnum) ? rev.to_s : rev
    end

    def to_s
      inspect
    end
  end
end
