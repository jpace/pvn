#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/subcommands/base/doc'
require 'pvn/subcommands/pct/options'
require 'pvn/subcommands/base/command'
require 'svnx/status/command'
require 'svnx/cat/command'

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
                "When more than one file is specified, the total is displayed",
                "as the last line." ]
    
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
        raise "ERROR: revisions not yet supported by pct"
        
        cmdargs[:revision] = options.revision

        info "cmdargs[:revision]: #{cmdargs[:revision]}"
        
        # we can't cache this, because we don't know if there has been an svn
        # update since the previous run:
        cmdargs[:use_cache] = false
        cmdargs[:limit] = nil
        cmdargs[:verbose] = true

        logargs = SVNx::LogCommandArgs.new cmdargs
        elmt    = PVN::IO::Element.new :local => path || '.'
        log     = elmt.log logargs
        entries = log.entries

        info "entries: #{entries}"
        entries.each do |entry|
          info "entry: #{entry}"
          info entry.paths
        end
      else
        compare_local_to_base options
      end
    end

    def compare_local_to_base options
      # do we support multiple paths?
      path = options.paths[0] || '.'

      if path
        cmdargs = SVNx::StatusCommandArgs.new :path => path, :use_cache => false

        total_local_count = 0
        total_svn_count = 0

        cmd = SVNx::StatusCommand.new cmdargs
        xml = cmd.execute
        entries = SVNx::Status::Entries.new :xmllines => xml
        entries.each do |entry|
          info "entry: #{entry}"
          info "entry.path: #{entry.path}".cyan
          info "entry.status: #{entry.status}".cyan

          if entry.status == 'added'
            # 100% added
          elsif entry.status == 'modified'
            catcmd = SVNx::CatCommand.new entry.path
            info "catcmd: #{catcmd}"
            
            svn_count = catcmd.execute.size
            info "svn_count: #{svn_count}"

            local_count = Pathname.new(entry.path).readlines.size
            info "local_count: #{local_count}"

            total_svn_count += svn_count
            total_local_count += local_count

            print_diff svn_count, local_count, entry.path
          elsif entry.status == 'deleted'
            # 100% deleted
          end
        end

        print_diff total_svn_count, total_local_count, 'total'
      end
    end

    def print_diff svn_count, local_count, name
      diff = local_count - svn_count
      diffpct = 100.0 * diff / svn_count
      
      printf "%8d %8d %8d %8.1f%% %s\n", svn_count, local_count, diff, diffpct, name
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
