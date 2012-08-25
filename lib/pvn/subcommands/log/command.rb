#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/log/formatter/entries_formatter'
require 'pvn/revision/entry'
require 'svnx/log/entries'
require 'pvn/subcommands/base/doc'
require 'pvn/subcommands/log/options'

module PVN::Subcommands::Log
  class Command
    include Loggable

    DEFAULT_LIMIT = 15

    def initialize args
      # RIEL::Log.level = Log::DEBUG

      options = PVN::Subcommands::Log::OptionSet.new 
      info "options: #{options}"
      options.process args

      if options.help 
        show_help
        return
      end

      info "revision: #{options.revision}".on_magenta

      path      = options.paths[0] || "."
      logargs   = SVNx::LogCommandArgs.new :limit => options.limit, :verbose => options.verbose, :revision => options.revision, :path => path
      elmt      = PVN::IO::Element.new :local => path || '.'
      log       = elmt.log logargs
      nentries  = log.entries.size

      # this should be refined to options.revision.head? && options.limit
      from_head = !options.revision
      from_tail = !options.limit && !options.revision
      
      # this dictates whether to show +N and/or -1:
      totalentries = options.limit || options.revision ? nil : nentries

      info "totalentries: #{totalentries}"

      # use_color, entries, from_head, from_tail
      ef = PVN::Log::EntriesFormatter.new options.format, log.entries, from_head, from_tail
      puts ef.format
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
      doc.examples   << [ "pvn log -l 10 -F",     "Prints the latest 10 entries, uncolorized." ]
      doc.examples   << [ "pvn log -r 122 -v",    "Prints log entry for revision 122, with the files in that change." ]

      doc.write $stdout
    end
  end
end
