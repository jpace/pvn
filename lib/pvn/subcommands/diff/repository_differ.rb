#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/subcommands/diff/options'
require 'tempfile'
require 'pvn/subcommands/diff/differ'

module PVN::Subcommands::Diff
  # this will replace RevisionEntry
  class Revision
    include Loggable
    
    attr_reader :value
    attr_reader :from
    attr_reader :to

    def initialize from, to = nil
      if to
        @from = from
        @to = to
      else
        @from, @to = from.split(':')
      end
    end

    def to_s
      str = @from.to_s
      if @to
        str << ':' << @to.to_s
      end
      str
    end

    def head?
      @to == nil
    end
  end

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

      # maps by log path to log entries
      logpaths = get_log_paths paths

      logpaths.sort.each do |name, paths|
        diff_entry name, paths
      end
    end

    def create_revision change, rev
      if change
        @revision = Revision.new change.to_i - 1, change.to_i
      elsif rev.kind_of? Array
        if rev.size == 2
          # this is some contorting, since -rx:y does not mean comparing the files
          # in changelist x; it means all the entries from x+1 through y, inclusive.

          ### $$$ this doesn't handle dates:
          @revision = Revision.new rev[0].to_i + 1, rev[0].to_i
        else
          from, to = rev[0].split(':')
          @revision = Revision.new from.to_i + 1, to
        end
      else
        nil
      end
    end

    def get_log_paths paths
      # maps by log path to log entries
      logpaths = Hash.new { |h, k| h[k] = Hash.new }

      paths.each do |path|
        info "path: #{path}"
        pathelmt = PVN::IO::Element.new :local => path
        pathinfo = pathelmt.get_info
        info "pathinfo: #{pathinfo.inspect}".on_black

        logentries = get_log_entries path, @revision
        logentries.each do |logentry|
          logentry.paths.each do |lp|
            next if lp.kind != 'file'
            logpaths[lp.name][logentry.revision] = [ lp, pathinfo ]
          end 
        end
      end
      logpaths
    end
    
    def cat elmt, rev
      catargs = SVNx::CatCommandArgs.new :path => elmt.svn + '@' + rev.to_s
      cmd = SVNx::CatCommand.new catargs
      cmd.execute
    end

    def show_as_modified elmt, path, fromrev, torev
      fromlines = cat elmt, fromrev
      tolines = cat elmt, torev
      run_diff path, fromlines, @revision.from - 1, tolines, @revision.to
    end

    def show_as_added elmt, path
      tolines = cat elmt, @revision.to
      run_diff path, nil, 0, tolines, @revision.to
    end

    def show_as_deleted elmt, path
      fromlines = cat elmt, @revision.from - 1
      run_diff path, fromlines, @revision.from - 1, nil, @revision.to
    end
    
    def diff_entry name, paths
      info "name: #{name}".blue

      revisions = paths.keys.sort

      firstrev = revisions[0]
      
      record = paths[firstrev]
      svnpath = record[1].url + name
      elmt = PVN::IO::Element.new :svn => svnpath
      action = record[0].action
      displaypath = name[1 .. -1]

      case action
      when 'A'
        show_as_added elmt, displaypath
      when 'D'
        show_as_deleted elmt, displaypath
      when 'M'
        lastrev = revisions[-1]
        fromrev, torev = if firstrev == lastrev
                           [ @revision.from - 1, @revision.to ]
                         else
                           [ firstrev.to_i - 1, lastrev ]
                         end
        show_as_modified elmt, displaypath, fromrev, torev
      end
    end

    def get_log_entries path, revision
      cmdargs = Hash.new
      cmdargs[:path] = path
      cmdargs[:revision] = revision.to_s
      cmdargs[:verbose] = true

      # should be conditional on revision:
      cmdargs[:use_cache] = false

      logargs = SVNx::LogCommandArgs.new cmdargs
      elmt    = PVN::IO::Element.new :local => path
      log     = elmt.log logargs
      entries = log.entries
    end
  end
end
