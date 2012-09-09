#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/subcommands/base/command'
require 'pvn/subcommands/status/options'
require 'pvn/status/formatter/entries_formatter'

module PVN::Subcommands::Status
  class Command < PVN::Subcommands::Base::Command

    DEFAULT_LIMIT = 15

    subcommands [ "status" ]
    description "Prints the status for locally changed files."
    usage       "[OPTIONS] FILE..."
    summary     [ "Prints the status for the given files, with colorized",
                  "output, and names sorted."
                ]

    optscls

    example "pvn status foo.rb",      "Prints the status of foo.rb."
    example "pvn status",             "Prints the status for locally changed files."
    example "pvn status --no-color",  "Prints the status, uncolorized, for locally changed files."
    
    def initialize options = nil
      return unless options

      # do we support multiple paths?
      path = options.paths[0] || '.'

      elmt = PVN::IO::Element.new :local => path || '.'
      entries = elmt.find_files_by_status

      entries = entries.sort_by { |n| n.path }

      fmtr = PVN::Status::EntriesFormatter.new options.color, entries
      puts fmtr.format
    end
  end
end
