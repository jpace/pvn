#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/log/formatter/entries_formatter'
require 'pvn/revision/entry'
require 'svnx/log/entries'
require 'pvn/subcommands/base/doc'
require 'pvn/subcommands/log/options'

module PVN::Subcommands::Base
  class Command
    include Loggable

    @@doc_for_class = Hash.new { |h, k| h[k] = PVN::Subcommands::Documentation.new }
    
    class << self
      def getdoc
        puts "self: #{self}"
        @@doc_for_class[self]
      end

      def subcommands sc
        getdoc.subcommands = sc
      end

      def description desc
        getdoc.description = desc
      end

      def usage usg
        getdoc.usage = usg
      end

      def summary smry
        getdoc.summary = smry
      end

      def options opts
        getdoc.options.concat opts
      end

      def optscls
        optmodule = self.to_s.sub %r{::\w+$}, ''
        optcls = optmodule + '::OptionSet'
        optset = instance_eval optcls + '.new'
        getdoc.options.concat optset.options
      end

      def example *ex
        getdoc.examples << ex
      end
    end

    def to_doc io
      doc = self.class.getdoc
      doc.write io
    end
  end
end

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

    # options PVN::Subcommands::Log::OptionSet.new.options
    optscls

    example "pvn log foo.rb",       "Prints the latest #{DEFAULT_LIMIT} log entries for foo.rb."
    example "pvn log -l 25 foo.rb", "Prints 25 log entries for the file."
    example "pvn log -3 foo.rb",    "Prints the log entry for revision (HEAD - 3)."
    example "pvn log +3 foo.rb",    "Prints the 3rd log entry."
    example "pvn log -l 10 -F",     "Prints the latest 10 entries, uncolorized."
    example "pvn log -r 122 -v",    "Prints log entry for revision 122, with the files in that change."
    
    def initialize args
      # RIEL::Log.level = Log::DEBUG

      options = PVN::Subcommands::Log::OptionSet.new 
      info "options: #{options}"
      options.process args

      return show_help if options.help 

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

      ef = PVN::Log::EntriesFormatter.new options.format, log.entries, from_head, from_tail
      puts ef.format
    end

    def show_help
      to_doc $stdout
    end
  end
end
