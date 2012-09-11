#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/subcommands/diff/options'
require 'tempfile'
require 'pvn/subcommands/diff/local_differ'
require 'pvn/subcommands/diff/base_differ'

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
      info "@from: #{@from}"
      info "@to: #{@to}"
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

  class RepositoryDiffer < BaseDiffer
    include Loggable

    attr_reader :whitespace
    attr_reader :revision
    
    def initialize options
      paths = options.paths
      paths = %w{ . } if paths.empty?

      info "paths: #{paths}"

      allentries = Array.new

      # we sort only the sub-entries, so the order in which paths were specified is preserved

      @whitespace = options.whitespace
      rev = options.revision
      change = options.change
      info "change: #{change}"
      info "rev: #{rev}"
      info "rev: #{rev.class}"

      if change
        @revision = Revision.new(change.to_i - 1, change.to_i)
      elsif rev.kind_of?(Array)
        if rev.size == 2
          # this is some contorting, since -rx:y does not mean comparing the files
          # in changelist x; it means all the entries from x+1 through y, inclusive.

          ### $$$ this doesn't handle dates:
          @revision = Revision.new(rev[0].to_i + 1, rev[0].to_i)
        else
          from, to = rev[0].split(':')
          @revision = Revision.new(from.to_i + 1, to)
        end
      end

      info "revision: #{@revision}; #{@revision.class}".on_blue

      # maps from pathnames to { :first, :last } revision updated.
      paths_to_revisions = Hash.new

      paths.each do |path|
        logentries = get_log_entries path, @revision
        logentries.each do |logentry|
          info "logentry: #{logentry}".yellow
          info "logentry.revision: #{logentry.revision}".yellow
          info "logentry.paths: #{logentry.paths}".yellow

          # should add the revision to this, so we know which is the first
          # version to compare against the last:

          logentry.paths.each do |lp|
            info "lp: #{lp.inspect}".cyan
            allentries << { :path => lp, :revision => logentry.revision }
            rec = paths_to_revisions[lp.name]
            if rec
              rec[:last] = logentry.revision
            else
              rec = { :first => logentry.revision, :action => lp.action }
            end
            paths_to_revisions[lp.name] = rec
          end 
        end
      end

      paths_to_revisions.sort.each do |name, revisions|
        puts "name: #{name}"
        puts "revisions: #{revisions}"
      end

      info "allentries: #{allentries}"

      allentries.each do |entry|
        info "entry: #{entry.inspect}".on_blue
        next if true
        case entry.status
        when 'modified'
          show_as_modified entry
        when 'deleted'
          show_as_deleted entry
        when 'added'
          show_as_added entry
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
