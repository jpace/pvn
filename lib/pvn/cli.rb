#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'optparse'
require 'pvn/log'
require 'pvn/cmdexec'
require 'singleton'

Log.level = Log::INFO
Log.set_widths(-15, 5, -35)

module PVN
  class MockLogExecutor < CommandExecutor
    include Loggable

    def file=(fname)
      @file = fname
    end

    def run args
      info "args: #{args}"
      cmd, subcmd, *cmdargs = args.split
      info "cmd: #{cmd}"
      info "subcmd: #{subcmd}"
      info "cmdargs: #{cmdargs}"

      limit = nil

      if idx = cmdargs.index("-l")
        info "idx: #{idx}"
        limit = cmdargs[idx + 1].to_i
      end

      info "limit: #{limit}"
      
      n_matches = 0
      output = Array.new
      IO.readlines(@file).each do |line|
        if limit && PVN::LogCommand::LOG_REVISION_LINE.match(line)
          n_matches += 1
          if n_matches > limit
            break
          end
        end
        output << line
      end

      # puts output

      output
    end
  end
end

module PVN
  VERSION = "0.0.1"
  
  class CLI
    include Loggable
    
    def self.execute stdout, arguments = Array.new
      mle = MockLogExecutor.new
      # mle.file = Pathname.new(File.dirname(__FILE__) + '/files/' + fname).expand_path

      subcmd = arguments.shift
      Log.info "subcmd: #{subcmd}"
      
      logargs = { :execute => false, :command_args => arguments, :executor => mle }
      LogCommand.new logargs
      return true if true

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
