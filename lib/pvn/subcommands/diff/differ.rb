#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/subcommands/diff/options'
require 'pvn/subcommands/base/command'
require 'tempfile'

module PVN::Subcommands::Diff
  class Differ
    include Loggable

    attr_reader :whitespace
    attr_reader :revision
    
    def initialize options
    end

    def to_revision_string rev
      rev ? "revision #{rev}" : "working copy"
    end

    def write_to_temp entry, lines
      Tempfile.open('pvn') do |to|
        topath = to.path
        info "topath: #{topath}"
        to.puts lines
        to.close
        cmd = "diff -u"
        label = " -L '#{entry.path} (revision 0)'"
        2.times do
          cmd << label
        end
        cmd << " #{frpath}"
        cmd << " #{entry.path}"
        IO.popen(cmd) do |io|
          puts io.readlines
        end
      end
    end

    def run_diff_command entry, fromrev, torev, frompath, topath
      info "whitespace: #{whitespace}"
      
      cmd = "diff -u"
      if whitespace
        cmd << " -x -b -x -w -x --ignore-eol-style"
      end

      [ fromrev, torev ].each do |rev|
        revstr = to_revision_string rev
        cmd << " -L '#{entry.path} (revision #{rev})'"
      end
      cmd << " #{frompath}"
      cmd << " #{topath}"
      IO.popen(cmd) do |io|
        puts io.readlines
      end
    end
  end

  class LocalDiffer < Differ    
    def initialize options
      super
      
      paths = options.paths
      paths = %w{ . } if paths.empty?

      info "paths: #{paths}".yellow

      allentries = Array.new

      # we sort only the sub-entries, so the order in which paths were specified is preserved

      @whitespace = options.whitespace

      paths.each do |path|
        elmt = PVN::IO::Element.new :local => path
        entries = elmt.find_files_by_status
        
        allentries.concat entries.sort_by { |n| n.path }
      end

      allentries.each do |entry|
        info "entry: #{entry.inspect}".on_blue
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

    def read_working_copy entry
      pn = Pathname.new entry.path
      pn.readlines
    end

    def show_as_added entry
      Tempfile.open('pvn') do |from|
        # from is an empty file
        from.close

        # I think this is always revision 0
        run_diff_command entry, 0, 0, from.path, entry.path
      end
    end

    def show_as_deleted entry
      elmt = PVN::IO::Element.new :local => entry.path

      svninfo = elmt.get_info
      lines = elmt.cat_remote

      Tempfile.open('pvn') do |from|
        from.puts lines
        from.close
        Tempfile.open('pvn') do |to|
          # to is an empty file
          to.close
          run_diff_command entry, svninfo.revision, nil, from.path, to.path
        end
      end
    end
    
    def show_as_modified entry
      # only doing working copy to remote now      
      elmt = PVN::IO::Element.new :local => entry.path

      svninfo = elmt.get_info
      remotelines = elmt.cat_remote

      fromrev = svninfo.revision
      torev = nil               # AKA working copy

      wclines = read_working_copy entry

      Tempfile.open('pvn') do |from|
        from.puts remotelines
        from.close
        Tempfile.open('pvn') do |to|
          to.puts wclines
          to.close
          run_diff_command entry, fromrev, torev, from.path, to.path
        end
      end
    end
  end

  class RepositoryDiffer
    include Loggable

    attr_reader :whitespace
    attr_reader :revision
    
    def initialize options
      paths = options.paths
      paths = %w{ . } if paths.empty?

      info "paths: #{paths}".yellow

      allentries = Array.new

      # we sort only the sub-entries, so the order in which paths were specified is preserved

      @whitespace = options.whitespace
      @revision = options.revision
      @change = options.change
      info "change: #{@change}".on_red
      info "revision: #{@revision}".on_red
      info "revision: #{@revision.class}".on_red

      # this is some contorting, since -rx:y does not mean comparing the files
      # in changelist x; it means all the entries from x+1 through y, inclusive.

      paths.each do |path|
        logentries = get_log_entries path, @revision
        logentries.each do |logentry|
          info "logentry: #{logentry}".yellow
          info "logentry.paths: #{logentry.paths}".yellow
          logentry.paths.each do |lp|
            info "lp: #{lp.inspect}"
          end
          # allentries.concat entries.sort_by { |n| n.path }
        end
      end
      info "allentries: #{allentries}"

      allentries.each do |entry|
        info "entry: #{entry.inspect}".on_blue
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
      cmdargs[:revision] = revision
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
