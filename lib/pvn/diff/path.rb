#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/action'

module PVN; module Diff; end; end

module PVN::Diff
  class Path
    attr_reader :name
    attr_reader :revisions
    attr_reader :action
    attr_reader :url
    
    # that's the root url, and revision can be a scalar or an array
    def initialize name, revision, action, url
      @name = name
      @revisions = Array.new
      add_revision revision
      @action = action.kind_of?(SVNx::Action) || SVNx::Action.new(action)
      @url = url
    end

    def add_revision rev
      if rev.kind_of?(Array)
        rev.each do |rv|
          @revisions << to_revision(rv)
        end
      else
        @revisions << to_revision(rev)
      end
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
