#!/usr/bin/ruby -w
# -*- ruby -*-

# require 'pvn/config'
# require 'pvn/svn/command/svncmd'
# require 'pvn/diff/diffopts'

require 'pvn/io/element'
require 'pvn/subcommands/diff/options'
require 'pvn/subcommands/base/command'
require 'tempfile'

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
          show_as_modified entry
        when 'deleted'
          show_as_deleted entry
        when 'added'
          show_as_added entry
        end
      end
    end

    def to_revision_string rev
      rev ? "revision #{rev}" : "working copy"
    end

    def read_working_copy entry
      pn = Pathname.new entry.path
      pn.readlines
    end

    def write_to_temp entry, lines
      Tempfile.open('pvn') do |to|
        topath = to.path
        info "topath: #{topath}"
        to.puts lines
        to.close
        cmd = "diff -u"
        label = " -L '#{entry.path} (revision 0)'"
        2.times do
          cmd << label
        end
        cmd << " #{frpath}"
        cmd << " #{entry.path}"
        IO.popen(cmd) do |io|
          puts io.readlines
        end
      end
    end

    def run_diff_command entry, fromrev, torev, frompath, topath
      cmd = "diff -u"
      [ fromrev, torev ].each do |rev|
        revstr = to_revision_string rev
        cmd << " -L '#{entry.path} (revision #{rev})'"
      end
      cmd << " #{frompath}"
      cmd << " #{topath}"
      IO.popen(cmd) do |io|
        puts io.readlines
      end
    end

    def show_as_added entry
      Tempfile.open('pvn') do |from|
        # from is an empty file
        from.close

        # I think this is always revision 0
        run_diff_command entry, 0, 0, from.path, entry.path
      end
    end

    def show_as_deleted entry
      elmt = PVN::IO::Element.new :local => entry.path

      svninfo = elmt.get_info
      lines = elmt.cat_remote

      Tempfile.open('pvn') do |from|
        from.puts lines
        from.close
        Tempfile.open('pvn') do |to|
          # to is an empty file
          to.close
          run_diff_command entry, svninfo.revision, nil, from.path, to.path
        end
      end
    end
    
    def show_as_modified entry
      # only doing working copy to remote now      
      elmt = PVN::IO::Element.new :local => entry.path

      svninfo = elmt.get_info
      remotelines = elmt.cat_remote

      fromrev = svninfo.revision
      torev = nil               # AKA working copy

      wclines = read_working_copy entry

      Tempfile.open('pvn') do |from|
        from.puts remotelines
        from.close
        Tempfile.open('pvn') do |to|
          to.puts wclines
          to.close
          run_diff_command entry, fromrev, torev, from.path, to.path
        end
      end
    end
  end
end
