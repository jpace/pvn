#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/action'
require 'pvn/diff/change'

module PVN; module Diff; end; end

module PVN::Diff
  class Path
    include Loggable
    
    attr_reader :name
    attr_reader :url
    attr_reader :changes
    
    # that's the root url
    def initialize name, revision, action, url
      @name = name
      @changes = Array.new
      add_change revision, action
      @url = url
    end

    def add_change rev, action
      info "rev: #{rev}".on_green
      @changes << Change.new(to_revision(rev), action)
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
