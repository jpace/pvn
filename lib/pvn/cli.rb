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

RIEL::Log.level = RIEL::Log::WARN
RIEL::Log.set_widths(-15, 5, -35)

module PVN
  class CLI
    include Loggable

    def self.run_command_with_output cmdcls, execute, args
      cmd = cmdcls.new :execute => execute, :command_args => args
      RIEL::Log.info "cmd: #{cmd}".on_black
      puts cmd.output
      true
    end
    
    def self.run_command_as_entries cmdcls, execute, args
      cmd = cmdcls.new :execute => execute, :command_args => args
      RIEL::Log.info "cmd: #{cmd}".on_black
      cmd.entries.each do |entry|
        entry.write
      end
      true
    end

    SUBCOMMANDS = [ LogCommand, DiffCommand, DescribeCommand ]

    def self.run_help arguments
      forwhat = arguments[0]

      cls = SUBCOMMANDS.find { |cls| cls::COMMAND == forwhat }
      if cls
        puts cls.to_doc
      else
        show_help
      end
    end
    
    def self.execute stdout, arguments = Array.new
      while arguments.size > 0
        arg = arguments.shift
        RIEL::Log.debug "arg: #{arg}"

        if arg == "--verbose"
          RIEL::Log.level = RIEL::Log::DEBUG
          next
        end

        case arg
        when "log"
          # return run_command_with_output LogCommand, true, arguments
          return run_command_as_entries LogCommand, true, arguments
        when "diff"
          return run_command_with_output DiffCommand, true, arguments
        when "describe"
          return run_command_with_output DescribeCommand, true, arguments
        when "pct"
          return run_command_with_output PctCommand, true, arguments
        when "help"
          return run_help arguments
        else
          puts "don't understand subcommand: #{arg}"
        end
      end

      # NOTE: the option -p/--path= is given as an example, and should be replaced in your application.
      options = {
        :path     => '~'
      }
      mandatory_options = %w(  )

      parser = OptionParser.new do |opts|
        opts.banner = <<-BANNER.gsub(/^          /, '')
          This application is wonderful because...

          Usage: #{File.basename($0)} [options]

          Options are:
        BANNER
        opts.separator ""
        opts.on("-p", "--path PATH", String,
                "This is a sample message.",
                "For multiple lines, add more strings.",
                "Default: ~") { |arg| options[:path] = arg }
        opts.on("-h", "--help",
                "Show this help message.") { stdout.puts opts; exit }
        opts.parse!(arguments)

        if mandatory_options && mandatory_options.find { |option| options[option.to_sym].nil? }
          stdout.puts opts; exit
        end
      end

      path = options[:path]

      # do stuff
      stdout.puts "To update this executable, look in lib/pvn/cli.rb"
    end
  end
end
