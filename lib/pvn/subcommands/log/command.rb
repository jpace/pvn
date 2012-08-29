#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/log/formatter/entries_formatter'
require 'pvn/subcommands/base/doc'
require 'pvn/subcommands/log/options'
require 'pvn/subcommands/base/command'

module PVN::Subcommands::Log
  class Command < PVN::Subcommands::Base::Command
    include Loggable

    DEFAULT_LIMIT = 15

    description "this is a description of log"
    subcommands [ "log" ]
    description "Print log messages for the given files."
    usage       "[OPTIONS] FILE..."
    summary     [ "Prints the log entries for the given files, with colorized",
                  "output. Unlike 'svn log', which prints all log entries, ",
                  "'pvn log' prints #{DEFAULT_LIMIT} entries by default.",
                  "As with other pvn subcommands, 'pvn log' accepts relative ",
                  "revisions."
                ]

    optscls

    example "pvn log foo.rb",       "Prints the latest #{DEFAULT_LIMIT} log entries for foo.rb."
    example "pvn log -l 25 foo.rb", "Prints 25 log entries for the file."
    example "pvn log -3 foo.rb",    "Prints the log entry for revision (HEAD - 3)."
    example "pvn log +3 foo.rb",    "Prints the 3rd log entry."
    example "pvn log -l 10 -F",     "Prints the latest 10 entries, uncolorized."
    example "pvn log -r 122 -v",    "Prints log entry for revision 122, with the files in that change."
    
    def initialize args
      options = PVN::Subcommands::Log::OptionSet.new 
      options.process args

      return show_help if options.help 

      path      = options.paths[0] || "."
      cmdargs   = Hash.new
      cmdargs[:path] = path
      
      [ :limit, :verbose, :revision ].each do |field|
        cmdargs[field] = options.send field
      end
      
      # we can't cache this, because we don't know if there has been an svn
      # update since the previous run:
      cmdargs[:use_cache] = false

      logargs   = SVNx::LogCommandArgs.new cmdargs
      elmt      = PVN::IO::Element.new :local => path || '.'
      log       = elmt.log logargs
      nentries  = log.entries.size

      # this should be refined to options.revision.head? && options.limit
      from_head = !options.revision
      from_tail = !options.limit && !options.revision
      
      # this dictates whether to show +N and/or -1:
      totalentries = options.limit || options.revision ? nil : nentries

      ef = PVN::Log::EntriesFormatter.new options.format, log.entries, from_head, from_tail
      puts ef.format
    end
  end
end
