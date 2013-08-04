#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'logue/loggable'
require 'logue/log'

require 'pvn'
require 'pvn/io/element'

require 'pvn/log/command'
require 'pvn/pct/command'
require 'pvn/status/command'
require 'pvn/diff/command'
require 'pvn/seek/command'

module PVN; module App; end; end

module PVN::App
  class Runner
    include Logue::Loggable

    SUBCOMMANDS = [ PVN::Log::Command,
                    PVN::Pct::Command,
                    PVN::Status::Command,
                    PVN::Diff::Command,
                    PVN::Seek::Command,
                    # DescribeCommand, 
                    # WhereCommand,
                    # UndeleteCommand,
                  ]

    def initialize io, args
      Logue::Log.level = Logue::Log::WARN
      Logue::Log.set_widths(-25, 5, -35)

      if args.empty?
        run_help args
      end
      
      while args.size > 0
        arg = args.shift
        info "arg: #{arg}"

        case arg
        when "-v", "--version"
          show_version
        when "--verbose"
          Logue::Log.level = Logue::Log::DEBUG
        when "help", "--help", "-h"
          run_help args
        else
          SUBCOMMANDS.each do |sc|
            if sc.matches_subcommand? arg
              # run command actually exits, but this makes it clearer
              return run_command sc, args
            end
          end
          $stderr.puts "ERROR: subcommand not valid: #{arg}"
          exit(-1)
        end
      end

      run_help args
    end

    def show_version
      puts "pvn, version #{PVN::VERSION}"
      puts "Written by Jeff Pace (jeugenepace@gmail.com)."
      puts "Released under the I Haven't Decided Yet License."
      exit 0
    end

    def run_command cmdcls, args
      begin
        cmdcls.new args
        exit 0
      rescue => e
        puts e.backtrace
        $stderr.puts e
        exit(-1)
      end
    end
    
    def run_help args
      forwhat = args[0]

      SUBCOMMANDS.each do |sc|
        info "sc: #{sc}"
        if sc.matches_subcommand? forwhat
          sc.new(%w{ --help })
          exit 0
        end
      end

      puts "usage: pvn [--verbose] <command> [<options>] [<args>]"
      puts "PVN, version #{PVN::VERSION}"
      puts
      puts "PVN has the subcommands:"
      SUBCOMMANDS.each do |sc|
        printf "   %-10s %s\n", sc.getdoc.subcommands[0], sc.getdoc.description
      end
      exit 0
    end
  end
end
