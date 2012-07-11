#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

require 'pvn/io/element'

require 'svnx/log/entries'
require 'pvn/app/cli/log/format'
require 'pvn/app/cli/log/clargs'
require 'pvn/app/cli/pct/clargs'

# the old ones:
require 'pvn/log/logcmd'
require 'pvn/diff/diffcmd'
require 'pvn/pct/pctcmd'
require 'pvn/describe'
require 'pvn/upp/uppcmd'
require 'pvn/wherecmd'

RIEL::Log.level = RIEL::Log::DEBUG
RIEL::Log.set_widths(-15, 5, -35)

module PVN
  class CLI
    include Loggable

    def initialize io, args
      while args.size > 0
        arg = args.shift
        info "arg: #{arg}"

        if arg == "--verbose"
          RIEL::Log.level = RIEL::Log::DEBUG
          next
        end

        if arg == "help" || arg == "--help" || arg == "-h"
          return self.class.run_help args
        end

        if arg == "log"
          clargs = PVN::App::Log::CmdLineArgs.new args
          elmt   = PVN::IO::Element.new :local => clargs.path || '.'
          log    = elmt.log SVNx::LogCommandArgs.new :limit => clargs.limit, :verbose => true

          fmt = PVN::App::Log::Format.new
          
          # this should be nil if the limit isn't set
          totalentries = clargs.limit ? nil : log.entries.size
          
          log.entries.each_with_index do |entry, idx|
            fmtlines = fmt.format entry, idx, totalentries
            
            puts fmtlines
            puts '-' * 55
          end
          
          return true
        end

        if arg == "pct"
          clargs = PVN::App::Pct::CmdLineArgs.new args
          info "clargs: #{clargs}"

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
          
          return
        end

        $stderr.puts "ERROR: subcommand not valid: #{arg}"
      end
    end

    # below is the old implementation. yes, I should have branched this.
    # =======================================================

    def self.run_command_with_output cmd
      RIEL::Log.info "cmd: #{cmd}".on_black
      puts cmd.output
      true
    end
    
    def self.run_command_as_entries cmd
      RIEL::Log.info "cmd: #{cmd}".on_black
      cmd.write_entries
      true
    end

    SUBCOMMANDS = [ LogCommand,
                    DiffCommand, 
                    DescribeCommand, 
                    PctCommand,
                    WhereCommand,
#                    UndeleteCommand,
                  ]
    
    def self.run_help args
      forwhat = args[0]

      cls = SUBCOMMANDS.find do |cls|
        cls.doc.subcommands.include? forwhat
      end

      if cls
        cls.to_doc
      else
        puts "usage: pvn [--verbose] <command> [<options>] [<args>]"
        puts "PVN, version #{PVN::VERSION}"
        puts
        puts "PVN has the subcommands:"
        SUBCOMMANDS.each do |sc|
          printf "   %-10s %s\n", sc.doc.subcommands[0], sc.doc.description
        end
      end
    end
    
    def self.execute stdout, args = Array.new
      while args.size > 0
        arg = args.shift
        RIEL::Log.debug "arg: #{arg}"

        if arg == "--verbose"
          RIEL::Log.level = RIEL::Log::DEBUG
          next
        end

        if arg == "help"
          return run_help args
        end

        SUBCOMMANDS.each do |sc|
          if sc.doc.subcommands.include?(arg)
            cmd = sc.new :execute => true, :command_args => args
            if cmd.has_entries?
              return run_command_as_entries cmd
            else
              return run_command_with_output cmd
            end
          end
        end
        
        $stderr.puts "ERROR: subcommand not valid: #{arg}"
      end
    end
  end
end
