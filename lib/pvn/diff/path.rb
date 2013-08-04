#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'riel/pathname'
require 'pvn/diff/change'
require 'pvn/diff/diffcmd'

module PVN::Diff
  class DiffSet
    include Logue::Loggable
    
    attr_reader :display_path
    attr_reader :from_lines
    attr_reader :from_revision
    attr_reader :to_lines
    attr_reader :to_revision
    attr_reader :whitespace

    def initialize display_path, from_lines, from_revision, to_lines, to_revision, whitespace
      @display_path = display_path
      @from_lines = from_lines
      @from_revision = from_revision
      @to_lines = to_lines
      @to_revision = to_revision
      @whitespace = whitespace
    end

    def run_diff
      info "display_path: #{@display_path}".color("fafa33")
      ext = Pathname.new(@display_path).extname
      info "ext: #{ext}".color("fafa11")

      cmd = Cmd.new @display_path, @from_revision, @to_revision, @from_lines, @to_lines, @whitespace
    end
  end

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
  end
end
