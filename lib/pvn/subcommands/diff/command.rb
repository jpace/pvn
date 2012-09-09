#!/usr/bin/ruby -w
# -*- ruby -*-

# require 'pvn/config'
# require 'pvn/svn/command/svncmd'
# require 'pvn/diff/diffopts'

require 'pvn/io/element'
require 'pvn/subcommands/diff/options'
require 'pvn/subcommands/base/command'

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
    
    def initialize options = nil
      return unless options

      paths = options.paths
      paths = %w{ . } if paths.empty?

      info "paths: #{paths}".yellow

      # we'll do all this ourselves.

      # find each modified file; if added, cat with +, if deleted, cat with -,
      # else run through diff.

      allentries = Array.new

      # we sort only the sub-entries, so the order in which paths were specified is preserved

      paths.each do |path|
        elmt = PVN::IO::Element.new :local => path
        entries = elmt.find_files_by_status

        allentries.concat entries.sort_by { |n| n.path }
      end

      allentries.each do |entry|
        info "entry: #{entry.inspect}".on_blue
        case entry.status
        when 'modified'
          puts entry.path
        when 'deleted'
          puts entry.path
        when 'added'
          show_as_added entry
        end
      end
    end

    def show_header entry, fromrev, torev
      puts "Index: #{entry.path}"
      puts "==================================================================="
      puts "--- #{entry.path}\t(revision #{fromrev})"
      puts "+++ #{entry.path}\t(revision #{torev})"
    end

    def show_diff_summary fromstart, fromend, tostart, toend
      puts "@@ -#{fromstart},#{fromend} +#{tostart},#{toend} @@"
    end

    def show_as_added entry
      # need to look up the revision

      show_header entry, 'dunno', 'hmmm'
      pn = Pathname.new entry.path
      lines = pn.readlines

      show_diff_summary 0, 0, 1, lines.size

      lines.each do |line|
        puts "+#{line}"
      end
    end
  end
end
