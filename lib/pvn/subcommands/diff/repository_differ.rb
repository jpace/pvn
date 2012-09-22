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
      end

      info "@revision: #{@revision}"

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

      logpaths.sort.each do |name, paths|
        diff_entry name, paths
      end
    end

    def show_as_added elmt, path
      remotelines = elmt.cat_remote @revision.to
      info "remotelines: #{remotelines}"

      svninfo = elmt.get_info

      fromrev = svninfo.revision
      torev = nil               # AKA working copy

      Tempfile.open('pvn') do |from|
        # from is an empty file
        from.close

        Tempfile.open('pvn') do |to|
          to.puts remotelines
          to.close
          
          # I think this is always revision 0
          run_diff_command path, 0, @revision.to, from.path, to.path
        end
      end
    end
    
    def diff_entry name, paths
      info "name: #{name}".blue
      info "paths: #{paths.inspect}".yellow

      revisions = paths.keys.sort
      info "revisions: #{revisions}".green

      firstrev = revisions[0]
      lastrev = revisions[-1]

      info "firstrev: #{firstrev}"
      info "lastrev: #{lastrev}"
      
      if firstrev == lastrev
        record = paths[firstrev]
        info "record[0]: #{record[0]}".cyan
        info "record[1]: #{record[1]}".cyan

        svnpath = record[1].url + name
        info "svnpath: #{svnpath}"

        elmt = PVN::IO::Element.new :svn => svnpath
        info "elmt: #{elmt}".green

        action = record[0].action
        info "action: #{action}"

        displaypath = name[1 .. -1]

        case action
        when 'A'
          show_as_added elmt, displaypath
        when 'D'
          show_as_deleted elmt, displaypath
        when 'M'
          show_as_modified elmt, displaypath
        end
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
