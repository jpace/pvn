#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'riel/pathname'
require 'pvn/diff/change'
require 'pvn/diff/diffset'

module PVN::Diff
  class Path
    include Logue::Loggable
    
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
      @changes << Change.new(to_revision(rev), action)
    end

    def to_revision rev
      # or should we convert this to Revision::Argument, and @revisions is
      # Revision::Range?
      rev.kind_of?(Fixnum) ? rev.to_s : rev
    end

    def run_diff displaypath, fromlines, fromrev, tolines, torev, whitespace
      ds = DiffSet.new displaypath, fromlines, fromrev, tolines, torev, whitespace
      ds.run_diff
    end

    def to_s
      "#{name}; #{url}"
    end

    def <=> other
      name <=> other.name
    end
  end
end
