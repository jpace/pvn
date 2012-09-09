#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/subcommands/pct/options'
require 'pvn/subcommands/base/command'
require 'svnx/info/command'
require 'svnx/status/command'
require 'svnx/cat/command'
require 'pvn/subcommands/pct/diffcount'
require 'set'

module PVN::Subcommands::Pct
  class Command < PVN::Subcommands::Base::Command

    DEFAULT_LIMIT = 15

    subcommands [ "pct" ]
    description "Compares revisions as a percentage of lines modified."
    usage       "[OPTIONS] FILE..."
    summary   [ "Compares to revisions, showing the changes in the size (length)",
                "of files that have been modified in the latter revision, to",
                "show the extent to which they have increased or decreased.",
                "The columns are:",
                " - length in svn repository",
                " - length in local version",
                " - difference",
                " - percentage change",
                " - file name",
                "The total numbers are displayed as the last line.",
                "Added and deleted files are not included." ]
    
    optscls

    example "pvn pct foo.rb",       "Prints the changes in foo.rb, working copy against BASE."
    example "pvn pct -r114:121",    "Prints the changes for all files, revision 114 against 121."
    example "pvn pct -rHEAD",       "Prints the changes, working copy against HEAD. (not yet supported)"
    example "pvn pct -r117",        "Prints the changes between revision 117 and the previous revision."
    example "pvn pct -7",           "Prints the changes between relative revision -7 and the previous revision."
    example "pvn pct -r31 -4",      "Prints the changes between revision 31 and relative revision -4."

    class << self
      # base command aliases new to init, so we're aliasing init to init2
      alias_method :init2, :init

      def init options
        if options.revision && !options.revision.empty?
          CommandRepository.init2 options
        else
          CommandLocal.init2 options
        end
      end
    end

    def initialize options = nil
    end

    def show_diff_counts options
      paths = options.paths
      paths = %w{ . } if paths.empty?

      info "paths: #{paths}"

      total = PVN::DiffCount.new 0, 0, 'total'

      paths.each do |path|
        diff_counts = get_diff_counts path, options
        
        diff_counts.each do |dc|
          total << dc
          dc.print
        end
      end

      total.print
    end
  end

  class CommandLocal < Command
    def initialize options
      show_diff_counts options
    end

    def get_diff_counts path, options
      elmt = PVN::IO::Element.new :local => path
      modified = elmt.find_modified_files

      total = PVN::DiffCount.new

      modified = modified.sort_by { |n| n.path }

      diff_counts = Array.new

      modified.each do |entry|
        catcmd      = SVNx::CatCommand.new entry.path
        svn_count   = catcmd.execute.size
        local_count = Pathname.new(entry.path).readlines.size
        
        dc = PVN::DiffCount.new svn_count, local_count, entry.path
        diff_counts << dc
      end

      diff_counts
    end
  end

  class CommandRepository < Command
    ### $$$ this belongs in Revision
    def get_from_to_revisions rev
      if rev.kind_of? Array
        if rev.size == 1
          if md = Regexp.new('(.+):(.+)').match(rev[0])
            return [ md[1], md[2] ]
          else
            return [ (rev[0].to_i - 1).to_s, rev[0] ]
          end
        else
          return [ rev[0], rev[1] ]
        end
      else
        info "rev: #{rev}".bold.white.on_red
      end
    end

    def get_line_count path, revision
      cmdargs = SVNx::CatCommandArgs.new :path => path, :revision => revision
      catcmd = SVNx::CatCommand.new cmdargs
      catcmd.execute.size
    end
    
    def initialize options
      show_diff_counts options
    end

    def get_diff_counts path, options
      diff_counts = Array.new

      revision = options.revision
      
      elmt = PVN::IO::Element.new :local => path
      modified = elmt.find_modified_entries revision

      modnames = modified.collect { |m| m.name }.sort.uniq

      fromrev, torev = get_from_to_revisions revision

      reporoot = elmt.repo_root

      direlmt = PVN::IO::Element.new :local => '.'
      svninfo = direlmt.get_info

      filter = svninfo.url.dup
      filter.slice! svninfo.root
      info "filter: #{filter}"
      filterre = Regexp.new '^' + filter + '/'
      
      modnames.each do |mod|
        fullpath = reporoot + mod
        elmt = PVN::IO::Element.new :path => fullpath

        next unless elmt.has_revision? fromrev
        next unless elmt.has_revision? torev
        next if elmt.get_info.kind == 'dir'

        from_count = get_line_count fullpath, fromrev
        to_count = get_line_count fullpath, torev

        name = mod.dup
        name.slice! filterre

        dc = PVN::DiffCount.new from_count, to_count, name
        diff_counts << dc
      end

      diff_counts
    end
  end

end
