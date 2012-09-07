#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/log/formatter/entries_formatter'
require 'pvn/subcommands/base/doc'
require 'pvn/subcommands/log/options'
require 'pvn/subcommands/base/command'

module PVN::Subcommands::Log
  class Command < PVN::Subcommands::Base::Command

    DEFAULT_LIMIT = 15

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
    example "pvn log -u barney",    "Prints log entries only for user 'barney', with the default limit."
    
    def initialize args
      options = instance_eval self.class.optscls + '.new'
      options.process args

      return show_help if options.help 

      path      = options.paths[0] || "."
      cmdargs   = Hash.new
      cmdargs[:path] = path
      
      [ :limit, :verbose, :revision ].each do |field|
        cmdargs[field] = options.send field
      end

      if options.user
        cmdargs[:limit] = nil
      end
      
      # we can't cache this, because we don't know if there has been an svn
      # update since the previous run:
      cmdargs[:use_cache] = false

      logargs = SVNx::LogCommandArgs.new cmdargs
      elmt    = PVN::IO::Element.new :local => path || '.'
      log     = elmt.log logargs
      entries = log.entries

      # this should be refined to options.revision.head?
      from_head = !options.revision
      from_tail = !options.limit && !options.revision

      info { "options: #{options}" }
      info { "options.user: #{options.user}" }

      if options.user
        entries = find_entries_for_user entries, options.user, options.limit
        info { "entries: #{entries}" }

        # don't show relative revisions, since we've got a slice out of the list:
        from_head = nil
        from_tail = nil
      end        
      
      ef = PVN::Log::EntriesFormatter.new options.format, entries, from_head, from_tail
      puts ef.format
    end

    def find_entries_for_user entries, user, limit
      entries = entries.select { |entry| entry.author == user }

      raise "ERROR: no matching log entries for '#{user}'" if entries.empty?

      info { "entries: #{entries}" }

      limit ? entries[0 ... limit] : entries
    end
  end
end
