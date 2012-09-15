#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/subcommands/diff/options'
require 'pvn/subcommands/base/command'
require 'pvn/subcommands/diff/local_differ'
require 'pvn/subcommands/diff/repository_differ'
require 'tempfile'
require 'synoption/exception'

module PVN::Subcommands::Diff
  class Command < PVN::Subcommands::Base::Command

    subcommands [ "diff" ]
    description "Shows the changes to files."
    usage       "[OPTIONS] FILE..."
    summary     [ "Compare two revisions, filtering through external programs.",
                  "For each file compared, the file extension is used to find",
                  "a diff program.",
                  "As with other pvn subcommands, 'pvn log' accepts relative ",
                  "revisions."
                ]

    optscls

    example "pvn diff foo.rb", "Compares foo.rb against the last updated version."
    example "pvn diff -3 StringExt.java", "Compares StringExt.java at change (HEAD - 3), using a Java-specific program such as DiffJ."
    example "pvn diff -r +4 -w", "Compares the 4th revision against the working copy, ignoring whitespace."
    example "pvn diff -c 1948", "Compares revision 1948 against 1947."
    example "pvn diff -c -8", "Compares revision (HEAD - 8) against (HEAD - 9)."
    example "pvn diff -c +7", "Compares revision (BASE + 7) against (BASE + 6)."
    
    def init options
      if options.revision && options.change
        raise PVN::OptionException.new "diff does not accept both revision '#{options.revision}' and change '#{options.change}' values"
      end

      if options.revision || options.change
        differ = RepositoryDiffer.new options
      else
        differ = LocalDiffer.new options
      end
    end
  end
end
