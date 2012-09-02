#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/subcommands/base/doc'
require 'pvn/subcommands/pct/options'
require 'pvn/subcommands/base/command'
require 'svnx/status/command'

module PVN::Subcommands::Pct
  class Command < PVN::Subcommands::Base::Command

    DEFAULT_LIMIT = 15

    subcommands [ "pct" ]
    description "Compares revisions as a percentage of lines modified."
    usage       "[OPTIONS] FILE..."
    summary     [ "Compares two revisions, showing output as the percentages",
                  "of lines added, changed, and deleted from the first revision",
                  "against the second revision.",
                  "By default, the BASE revision is compared against the working copy."
                ]

    optscls

    example "pvn pct foo.rb",       "Prints the changes in foo.rb, working copy against BASE."
    example "pvn pct -r114:121",    "Prints the changes for all files, revision 114 against 121."
    example "pvn pct -rHEAD",       "Prints the changes, working copy against HEAD."
    example "pvn pct -r117",        "Prints the changes between revision 117 and the previous revision."
    example "pvn pct -7",           "Prints the changes between relative revision -7 and the previous revision."
    example "pvn pct -r31 -4",      "Prints the changes between revision 31 and relative revision -4."
    
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
        info "no revision"
        info "options.paths: #{options.paths}"

        if options.paths[0]
          info "options.paths[0]: #{options.paths[0]}"

          cmdargs = SVNx::StatusCommandArgs.new :path => '.'
          cmd = SVNx::StatusCommand.new :cmdargs => cmdargs
          xml = cmd.execute.join ''
          entries = SVNx::Status::Entries.new :xml => SVNx::Status::XMLEntries.new(xml)
          
        end
      end
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
