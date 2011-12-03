#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'optparse'
require 'pvn/log'
require 'pvn/command/cmdexec'
require 'pvn/diff'
require 'pvn/describe'

RIEL::Log.level = Log::WARN
RIEL::Log.set_widths(-15, 5, -35)

module PVN
  VERSION = "0.0.1"
  
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
    
    def self.execute stdout, arguments = Array.new
      subcmd = arguments.shift
      RIEL::Log.debug "subcmd: #{subcmd}"

      case subcmd
      when "log"
        # return run_command_with_output LogCommand, true, arguments
        return run_command_as_entries LogCommand, true, arguments
      when "diff"
        return run_command_with_output DiffCommand, true, arguments
      when "describe"
        return run_command_with_output DescribeCommand, true, arguments
      when "help"
        return run_command_with_output DescribeCommand, true, arguments
      else
        puts "don't understand subcommand: #{subcmd}"
      end

      # NOTE: the option -p/--path= is given as an example, and should be replaced in your application.
      options = {
        :path     => '~'
      }
      mandatory_options = %w(  )

      parser = OptionParser.new do |opts|
        opts.banner = <<-BANNER.gsub(/^          /,'')
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
