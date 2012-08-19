#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/app/cli/subcommands/log/clargs'
require 'pvn/io/element'
require 'pvn/log/formatter'
require 'pvn/revision/entry'
require 'svnx/log/entries'
require 'pvn/app/cli/subcommands/base/doc'
require 'pvn/app/cli/subcommands/log/options'

module PVN; module App; end; end

module PVN::App::Log
  class Command
    include Loggable

    DEFAULT_LIMIT = 15

    def initialize args
      RIEL::Log.level = Log::DEBUG

      optset = PVN::App::CLI::Log::OptionSet.new 

      info "optset: #{optset}"

      clargs = PVN::App::Log::CmdLineArgs.new optset, args
      if clargs.help 
        show_help
        return
      end
      
      logargs = SVNx::LogCommandArgs.new :limit => clargs.limit, :verbose => clargs.verbose, :revision => clargs.revision, :path => clargs.path
      elmt    = PVN::IO::Element.new :local => clargs.path || '.'
      log     = elmt.log logargs

      fmt     = PVN::Log::Formatter.new clargs.format

      nentries = log.entries.size
      
      # this dictates whether to show +N and/or -1:
      totalentries = clargs.limit || clargs.revision ? nil : nentries

      info "totalentries: #{totalentries}"
      
      log.entries.each_with_index do |entry, idx|
        fmtlines = fmt.format_entry entry, idx, totalentries
        
        puts fmtlines

        if idx < nentries - 1
          puts '-' * 55
        end
      end
    end

    def show_help
      puts "pvn log <options>"
      doc = PVN::App::Subcommand::Documentation.new
      doc.subcommands = [ "log" ]
      doc.description = "Print log messages for the given files."
      doc.usage       = "[OPTIONS] FILE..."
      doc.summary     = [ "Prints the log entries for the given files, with colorized",
                          "output. Unlike 'svn log', which prints all log entries, ",
                          "'pvn log' prints #{DEFAULT_LIMIT} entries by default.",
                          "As with other pvn subcommands, 'pvn log' accepts relative ",
                          "revisions."
                        ]
      doc.options.concat PVN::App::CLI::Log::OptionSet.new.options

      doc.examples   << [ "pvn log foo.rb",       "Prints the latest #{DEFAULT_LIMIT} log entries for foo.rb." ]
      doc.examples   << [ "pvn log -l 25 foo.rb", "Prints 25 log entries for the file." ]
      doc.examples   << [ "pvn log -3 foo.rb",    "Prints the log entry for revision (HEAD - 3)." ]
      doc.examples   << [ "pvn log +3 foo.rb",    "Prints the 3rd log entry." ]
      # doc.examples   << [ "pvn log -l 10 -F",     "Prints the latest 10 entries, unformatted." ]
      doc.examples   << [ "pvn log -r 122 -v",    "Prints log entry for revision 122, with the files in that change." ]

      doc.write $stdout
    end
  end
end
