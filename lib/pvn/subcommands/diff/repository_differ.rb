#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/subcommands/diff/options'
require 'tempfile'
require 'pvn/subcommands/diff/differ'
require 'pvn/subcommands/diff/logpaths'
require 'pvn/revision'
require 'pp'

module PVN::Subcommands::Diff
  class RepositoryDiffer < Differ
    include Loggable

    attr_reader :whitespace
    attr_reader :revision
    
    def initialize options
      paths = options.paths
      paths = %w{ . } if paths.empty?

      # we sort only the sub-entries, so the order in which paths were specified is preserved

      @whitespace = options.whitespace
      rev = options.revision
      info "rev: #{rev}".cyan

      change = options.change
      info "change: #{change}".cyan

      ### $$$ add handling revision against head:
      ### $$$ pvn diff -r 143
      ### $$$ pvn diff -r143:HEAD

      @revision = create_revision change, rev

      info "@revision: #{@revision}"

      paths.each do |path|
        info "path: #{path}"
      end

      # maps by log path to log entries
      lps = LogPaths.new @revision, paths

      names = lps.elements.collect { |lpelmt| lpelmt.name }
      info "names: #{names}".magenta

      names.sort.each do |name|
        info "name: #{name}".magenta
        lpelmt = lps.elements.detect { |el| el.name == name }
        info "lpelmt: #{lpelmt}".magenta
        diff_element lpelmt
      end
      
      info "@revision: #{@revision}".red
      
      if @revision.working_copy?
        info "@revision.working_copy?: #{@revision.working_copy?}".red
        paths.each do |path|
          info "path: #{path}".on_blue
          elmt = PVN::IO::Element.new :local => path
          entries = elmt.find_files_by_status
          info "entries: #{entries}".yellow

          entries.sort_by { |n| n.path }.each do |entry|
            info "entry: #{entry}".cyan
            case entry.status
            when 'modified'
              # show_as_modified 
            when 'added'
              # 
            when 'deleted'
              # 
            end
            # lpentries[entry.path][:working_copy] = [ lp, :working_copy ]
          end
          # allentries.concat entries.sort_by { |n| n.path }
        end
      end
    end

    def create_revision change, rev
      if change
        @revision = PVN::RevisionRange.new change.to_i - 1, change.to_i
      elsif rev.kind_of? Array
        if rev.size == 2
          # this is some contorting, since -rx:y does not mean comparing the files
          # in changelist x; it means all the entries from x+1 through y, inclusive.

          ### $$$ this doesn't handle dates:
          @revision = PVN::RevisionRange.new rev[0].to_i + 1, rev[0].to_i
        else
          from, to = rev[0].split(':')
          info "from: #{from}"
          info "to  : #{to}"
          @revision = PVN::RevisionRange.new from.to_i + 1, to
        end
      else
        info "revision argument not handled: #{rev}".red
        nil
      end
    end

    def show_as_modified elmt, path, fromrev, torev
      fromlines = elmt.cat fromrev
      tolines = elmt.cat torev
      fromrev = @revision.from.value.to_i - 1
      run_diff path, fromlines, fromrev, tolines, @revision.to
    end

    def show_as_added elmt, path
      tolines = elmt.cat @revision.to
      run_diff path, nil, 0, tolines, @revision.to
    end

    def show_as_deleted elmt, path
      fromrev = @revision.from.value.to_i - 1
      fromlines = elmt.cat fromrev
      run_diff path, fromlines, fromrev, nil, @revision.to
    end
    
    def diff_element lpelmt
      info "lpelmt.name: #{lpelmt.name}".magenta
      info "lpelmt: #{lpelmt}".magenta
      name = lpelmt.name

      pp lpelmt
      revisions = lpelmt.revisions
      info "revisions: #{revisions}".magenta
      
      # all the paths will be the same, so any can be selected (actually, a
      # logpath should have multiple revisions)
      svnurl = lpelmt.svninfo.url
      info "svnurl: #{svnurl}"
      
      svnpath = svnurl + name
      info "svnpath: #{svnpath}"
      elmt = PVN::IO::Element.new :svn => svnpath

      action = lpelmt.logentrypath.action
      info "action: #{action}"
      displaypath = name[1 .. -1]
      info "displaypath: #{displaypath}"

      firstrev = revisions[0]
      lastrev = revisions[-1]
      
      case action
      when 'A'
        show_as_added elmt, displaypath
      when 'D'
        show_as_deleted elmt, displaypath
      when 'M'
        lastrev = revisions[-1]
        fromrev, torev = if firstrev == lastrev
                           [ @revision.from.value.to_i - 1, @revision.to ]
                         else
                           [ firstrev.to_i - 1, lastrev ]
                         end
        show_as_modified elmt, displaypath, fromrev, torev
      end


      # lprevisions = lpelmt.collect { |lp| lp.revision }
      # info "lprevisions: #{lprevisions}".red
    end
  end
end
