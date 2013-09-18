#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/base/action'
require 'logue/loggable'

module PVN; module Diff; end; end

# A Path Revision is the change to a path within a changelist. 
module PVN::Diff
  class Change
    include Logue::Loggable
    
    attr_reader :revision
    attr_reader :action
    
    def initialize revision, action
      @revision = to_revision(revision)
      @action = action.kind_of?(SVNx::Action) || SVNx::Action.new(action)
    end

    def to_revision rev
      # or should we convert this to Revision::Argument, and @revisions is
      # Revision::Range?
      rev.kind_of?(Fixnum) ? rev.to_s : rev
    end
  end
end
