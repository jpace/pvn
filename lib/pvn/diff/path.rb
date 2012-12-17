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
      info "rev: #{rev}"
      @changes << Change.new(to_revision(rev), action)
    end

    def to_revision rev
      # or should we convert this to Revision::Argument, and @revisions is
      # Revision::Range?
      rev.kind_of?(Fixnum) ? rev.to_s : rev
    end

    def to_revision_string rev
      rev ? "revision #{rev}" : "working copy"
    end

    def run_diff_command displaypath, fromrev, torev, frompath, topath, whitespace
      cmd = "diff -u"
      if whitespace
        cmd << " -w"
      end

      [ fromrev, torev ].each do |rev|
        revstr = to_revision_string rev
        cmd << " -L '#{displaypath}\t(#{revstr})'"
      end
      cmd << " #{frompath}"
      cmd << " #{topath}"

      info "cmd: #{cmd}"

      $io.puts "Index: #{displaypath}"
      $io.puts "==================================================================="
      IO.popen(cmd) do |io|
        $io.puts io.readlines
      end
    end

    def run_diff displaypath, fromlines, fromrev, tolines, torev, whitespace
      Tempfile.open('pvn') do |from|
        if fromlines
          from.puts fromlines
        end
        from.close

        Tempfile.open('pvn') do |to|
          if tolines
            to.puts tolines
          end
          to.close
          
          run_diff_command displaypath, fromrev, torev, from.path, to.path, whitespace
        end
      end
    end
  end
end
