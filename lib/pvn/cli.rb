#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'optparse'
require 'pvn/log'
require 'pvn/command/cmdexec'
require 'pvn/diff/diffcmd'
require 'pvn/pct/pctcmd'
require 'pvn/describe'
require 'pvn/upp/uppcmd'

RIEL::Log.level = RIEL::Log::WARN
RIEL::Log.set_widths(-15, 5, -35)

module PVN
  class CLI
    include Loggable

    def self.run_command_with_output cmd
      RIEL::Log.info "cmd: #{cmd}".on_black
      puts cmd.output
      true
    end
    
    def self.run_command_as_entries cmd
      RIEL::Log.info "cmd: #{cmd}".on_black
      cmd.entries.each do |entry|
        entry.write
      end
      true
    end

    SUBCOMMANDS = [ LogCommand, DiffCommand, DescribeCommand, PctCommand ]

    def self.run_help args
      forwhat = args[0]

      cls = SUBCOMMANDS.find { |cls| cls::COMMAND == forwhat }
      if cls
        cls.to_doc
      else
        puts "usage: pvn [--verbose] <command> [<options>] [<args>]"
        puts "PVN, version #{PVN::VERSION}"
        puts
        puts "PVN is a front-end for the subcommands:"
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
          puts "sc: #{sc}"
          if sc.doc.subcommands.include?(arg)
            cmd = sc.new :execute => true, :command_args => args
            if cmd.has_entries?
              return run_command_as_entries cmd
            else
              return run_command_with_output cmd
            end
          end
        end
        
        puts "don't understand subcommand: #{arg}"
      end
    end
  end
end
