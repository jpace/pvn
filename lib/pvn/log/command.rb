#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/log/formatter/entries_formatter'
require 'pvn/log/options'
require 'pvn/command/command'
require 'pvn/log/entries'
require 'pvn/log/user_entries'

module PVN::Log
  class Command < PVN::Command::Command

    DEFAULT_LIMIT = 15

    subcommands [ "log" ]
    description "Print log messages for the given files."
    usage       "[OPTIONS] FILE..."
    summary     [ "Prints the log entries for the given files, with colorized ",
                  "output. Unlike 'svn log', which prints all log entries, ",
                  "'pvn log' prints #{DEFAULT_LIMIT} entries by default. ",
                  "As with other pvn subcommands, 'pvn log' accepts relative ",
                  "revisions."
                ]

    optscls

    example "pvn log foo.rb",           "Prints the latest #{DEFAULT_LIMIT} log entries for foo.rb."
    example "pvn log -l 25 foo.rb",     "Prints 25 log entries for the file."
    example "pvn log -3 foo.rb",        "Prints the log entry for revision (HEAD - 3)."
    example "pvn log +3 foo.rb",        "Prints the 3rd log entry."
    example "pvn log -l 10 --no-color", "Prints the latest 10 entries, uncolorized."
    example "pvn log -r 122 -f",        "Prints log entry for revision 122, including the files in that change."
    example "pvn log -u barney",        "Prints log entries only for user 'barney', with the default limit."
    
    def init options
      paths = options.paths

      paths = %w{ . } if paths.empty?

      info "paths: #{paths}"

      allentries = Array.new

      info "options.user: #{options.user}".color('#4a4a33')

      if options.user
        entcls = UserEntries
        paths.each do |path|
          allentries.concat entcls.new(path, options).entries
        end
      else
        entcls = Entries
        paths.each do |path|
          allentries.concat entcls.new(path, options).entries
        end
      end

      # we can show relative revisions for a single path, without filtering by
      # user, or by limit or revision.

      show_relative = !options.user && paths.size == 1 && !options.revision
      
      # this should be refined to options.revision.head?
      from_head = show_relative
      from_tail = show_relative && !options.limit

      ef = PVN::Log::EntriesFormatter.new options.color, allentries, from_head, from_tail
      $io.puts ef.format
    end
  end
end
