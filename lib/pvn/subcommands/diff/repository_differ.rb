#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/subcommands/diff/options'
require 'pvn/subcommands/diff/differ'
require 'pvn/subcommands/diff/logpaths'
require 'pvn/subcommands/diff/revision'
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

      @revision = RevisionRange.new change, rev

      info "@revision: #{@revision}"

      logpaths = LogPaths.new @revision, paths

      name_to_logpath = logpaths.to_map

      name_to_logpath.sort.each do |name, logpath|
        info "name: #{name}".magenta
        info "logpath: #{logpath}".magenta
        diff_logpath logpath
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
    
    def diff_logpath logpath
      info "logpath.name: #{logpath.name}".magenta
      info "logpath: #{logpath}".magenta
      name = logpath.name

      revisions = logpath.revisions
      info "revisions: #{revisions}".magenta
      
      # all the paths will be the same, so any can be selected (actually, a
      # logpath should have multiple revisions)
      svnurl = logpath.svninfo.url
      info "svnurl: #{svnurl}"
      
      svnpath = svnurl + name
      info "svnpath: #{svnpath}"
      elmt = PVN::IO::Element.new :svn => svnpath

      action = logpath.logentrypath.action
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
    end
  end
end
