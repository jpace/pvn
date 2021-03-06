#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/command/command'
require 'pvn/status/options'
require 'pvn/status/formatter/entries_formatter'

module PVN::Status
  class Command < PVN::Command::Command

    DEFAULT_LIMIT = 15

    subcommands [ "status", "st" ]
    description "Prints the status for locally changed files."
    usage       "[OPTIONS] FILE..."
    summary     [ "Prints the status for the given files, with colorized ",
                  "output, and names sorted."
                ]

    optscls

    example "pvn status foo.rb",      "Prints the status of foo.rb."
    example "pvn status",             "Prints the status for locally changed files."
    example "pvn status --no-color",  "Prints the status, uncolorized, for locally changed files."
    
    def init options
      info "options: #{options}"
      paths = options.paths

      paths = %w{ . } if paths.empty?

      allentries = Array.new

      # we sort only the sub-entries, so the order in which paths were specified is preserved

      paths.each do |path|
        elmt = PVN::IO::Element.new :local => path
        entries = elmt.find_files_by_status

        allentries.concat entries.sort_by { |n| n.path }
      end

      fmtr = PVN::Status::EntriesFormatter.new options.color, allentries
      $io.puts fmtr.format
    end
  end
end
