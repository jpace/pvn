#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/util'
require 'pvn/command'

module PVN
  class DiffCommand < Command
    COMMAND = "diff"

    subcommands [ COMMAND ]
    description "Displays differences."
    usage "[OPTIONS] FILE..."
    summary [ "  Compares the given files." ]
    
    examples << [ "pvn diff foo.rb", "Compares foo.rb against the last updated version." ]
    
    has_option :whitespace, '-w', "whether to consider whitespace", :default => false, :negate => [ %r{^--no-?whitespace} ]
    has_option :javadiff, '-j', "specify the program for diffing java files"
    has_revision_option

    def run
      info "running!".on_blue

      # this will be on a file-by-file basis, using specific diff programs for the file type.

      super
    end
  end
end
