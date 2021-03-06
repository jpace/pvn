#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/pct/options'
require 'pvn/command/command'
require 'pvn/pct/local_differ'
require 'pvn/pct/repository_differ'

module PVN::Pct
  class Command < PVN::Command::Command

    subcommands [ "pct" ]
    description "Compares revisions as a percentage of lines modified."
    usage       "[OPTIONS] FILE..."
    summary   [ "Compares two revisions, showing the changes in the size (length) ",
                "of files that have been modified in the latter revision, to ",
                "show the extent to which they have increased or decreased. ",
                "\n",
                "NOWRAP",
                "The columns are:",
                " - length in svn repository",
                " - length in local version",
                " - difference",
                " - percentage change",
                " - file name",
                "/NOWRAP",
                "The total numbers are displayed as the last line. ",
                "Added and deleted files are not included." ]
    
    optscls

    example "pvn pct foo.rb",       "Prints the changes in foo.rb, working copy against BASE."
    example "pvn pct -r114:121",    "Prints the changes for all files, revision 114 against 121."
    example "pvn pct -rHEAD",       "Prints the changes, working copy against HEAD. (not yet supported)"
    example "pvn pct -r117",        "Prints the changes between revision 117 and the previous revision."
    example "pvn pct -7",           "Prints the changes between relative revision -7 and the previous revision."
    example "pvn pct -r31 -4",      "Prints the changes between revision 31 and relative revision -4."

    def init options
      cls = options.revision && !options.revision.empty? ? RepositoryDiffer : LocalDiffer
      cls.new options
    end
  end
end
