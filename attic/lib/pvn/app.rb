#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

require 'pvn/io/element'

require 'pvn/subcommands/log/command'
require 'pvn/subcommands/pct/command'
require 'pvn/subcommands/status/command'
require 'pvn/subcommands/diff/command'

# the old ones:
# require 'pvn/diff/diffcmd'
# require 'pvn/pct/pctcmd'

# the new ones:
# require 'pvn/describe'
# require 'pvn/upp/uppcmd'
# require 'pvn/wherecmd'

module PVN; module App; end; end

module PVN::App
  class Runner
    include Loggable

    def initialize io, args
      RIEL::Log.level = RIEL::Log::WARN
      RIEL::Log.set_widths(-25, 5, -35)

      if args.empty?
        run_help args
      end
      
      while args.size > 0
        arg = args.shift
        info "arg: #{arg}"

        case arg
        when "--verbose"
          RIEL::Log.level = RIEL::Log::DEBUG
        when "help", "--help", "-h"
          run_help args
        else
          SUBCOMMANDS.each do |sc|
            if sc.matches_subcommand? arg
              # run command actually exits
              run_command sc, args
            end
          end
          $stderr.puts "ERROR: subcommand not valid: #{arg}"
          exit(-1)
        end
      end

      run_help args
    end

    def run_command cmdcls, args
      begin
        cmdcls.new args
        exit(0)
      rescue => e
        puts e.backtrace
        $stderr.puts e
        exit(-1)
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

    SUBCOMMANDS = [ PVN::Subcommands::Log::Command,
                    PVN::Subcommands::Pct::Command,
                    PVN::Subcommands::Status::Command,
                    PVN::Subcommands::Diff::Command,
#                    DescribeCommand, 
#                    WhereCommand,
#                    UndeleteCommand,
                  ]
    
    def run_help args
      forwhat = args[0]

      cls = SUBCOMMANDS.find do |cls|
        cls.getdoc.subcommands.include? forwhat
      end

      if cls
        cls.to_doc
      else
        puts "usage: pvn [--verbose] <command> [<options>] [<args>]"
        puts "PVN, version #{PVN::VERSION}"
        puts
        puts "PVN has the subcommands:"
        SUBCOMMANDS.each do |sc|
          printf "   %-10s %s\n", sc.getdoc.subcommands[0], sc.getdoc.description
        end
      end
      exit(0)
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
