#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/subcommands/pct/options'
require 'pvn/subcommands/base/command'
require 'svnx/info/command'
require 'svnx/status/command'
require 'svnx/cat/command'
require 'set'

module PVN::Subcommands::Pct
  class DiffCount
    attr_reader :from
    attr_reader :to

    def initialize from = 0, to = 0
      @from = from
      @to = to
    end

    def print name
      diff = to - from
      diffpct = diff == 0 ? 0 : 100.0 * diff / from
      
      printf "%8d %8d %8d %8.1f%% %s\n", from, to, diff, diffpct, name
    end

    def << diff
      @from += diff.from
      @to += diff.to
    end
  end

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
    example "pvn pct -r114:121",    "Prints the changes for all files, revision 114 against 121. (not yet supported)"
    example "pvn pct -rHEAD",       "Prints the changes, working copy against HEAD. (not yet supported)"
    example "pvn pct -r117",        "Prints the changes between revision 117 and the previous revision. (not yet supported)"
    example "pvn pct -7",           "Prints the changes between relative revision -7 and the previous revision. (not yet supported)"
    example "pvn pct -r31 -4",      "Prints the changes between revision 31 and relative revision -4. (not yet supported)"
    
    def initialize args
      options = PVN::Subcommands::Pct::OptionSet.new 
      options.process args

      return show_help if options.help 

      info "options: #{options}"

      path    = options.paths[0] || "."
      cmdargs = Hash.new

      cmdargs[:path] = path

      if options.revision && !options.revision.empty?
        compare_by_revisions options
      else
        compare_local_to_base options
      end
    end

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

    def compare_by_revisions options
      # what was modified between the revisions?

      path = options.paths[0] || "."

      elmt = PVN::IO::Element.new :local => path || '.'
      modified = elmt.find_modified_entries options.revision

      modnames = modified.collect { |m| m.name }.sort.uniq

      info "modnames: #{modnames.inspect}".yellow

      rev = options.revision

      info "rev: #{rev}; #{rev.class}".blue.on_yellow
      info "rev: #{rev.inspect}; #{rev.class}".blue.on_yellow

      fromrev, torev = get_from_to_revisions options.revision

      info "fromrev: #{fromrev}; torev: #{torev}".black.on_green
      info "fromrev: #{fromrev.class}; torev: #{torev.class}".black.on_green

      total = DiffCount.new

      reporoot = elmt.repo_root

      modnames.each do |mod|
        info "mod: #{mod}".yellow

        fullpath = reporoot + mod
        
        info "fullpath: #{fullpath}".cyan

        elmt = PVN::IO::Element.new :path => fullpath
        info "checking fromrev ... #{fromrev}".yellow
        next unless elmt.has_revision? fromrev
        info "checking torev ... #{torev}".yellow
        next unless elmt.has_revision? torev
        next if elmt.get_info.kind == 'dir'

        from_count = get_line_count fullpath, fromrev
        info "from_count: #{from_count}".red

        to_count = get_line_count fullpath, torev
        info "to_count: #{to_count}".red

        dc = DiffCount.new from_count, to_count
        total << dc
        dc.print mod
      end

      total.print 'total'
    end

    def get_line_count path, revision
      cmdargs = SVNx::CatCommandArgs.new :path => path, :revision => revision
      catcmd = SVNx::CatCommand.new cmdargs
      info "catcmd: #{catcmd}"
      
      count = catcmd.execute.size
      info "count: #{count}"

      count
    end

    def compare_local_to_base options
      # do we support multiple paths?
      path = options.paths[0] || '.'

      elmt = PVN::IO::Element.new :local => path || '.'
      modified = elmt.find_modified_files

      total = DiffCount.new    

      modified.each do |entry|
        catcmd = SVNx::CatCommand.new entry.path
        info "catcmd: #{catcmd}"
          
        svn_count = catcmd.execute.size
        info "svn_count: #{svn_count}"
        
        local_count = Pathname.new(entry.path).readlines.size
        info "local_count: #{local_count}"

        dc = DiffCount.new svn_count, local_count
        total << dc
        dc.print entry.path
      end

      total.print 'total'
    end
  end
end

__END__

      elmt = PVN::IO::Element.new :local => clargs.path || '.'
      info "elmt: #{elmt}".red

      stats = { :modified => 0, :added => 0, :deleted => 0 }

      if elmt.directory?
        info "elmt.directory?: #{elmt.directory?}"

        # $$$ todo: recurse even when local has been removed (this is the
        # awaited "pvn find").
        
        changed = Array.new
        elmt.local.find do |fd|
          info "fd: #{fd}; #{fd.class}"
          Find.prune if fd.rootname.to_s == '.svn'
          if fd.file?
            subelmt = PVN::IO::Element.new :local => fd.to_s
            info "subelmt: #{subelmt}"
            status = subelmt.status
            info "status: #{status}".red
          end
        end

        # info "changed: #{changed}"
      elsif elmt.file?
        info "elmt.local: #{elmt.local}".cyan

        status = elmt.status
        info "status: #{status}"

        case status
        when "added"
          info "elmt: #{elmt}".green
        when "modified"
          info "elmt: #{elmt}".yellow
        when "deleted"
          info "elmt: #{elmt}".red
        else
          info "elmt: #{elmt}".cyan
        end
      end
    end
  end
end
