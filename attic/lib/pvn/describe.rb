#!/usr/bin/ruby -w
# -*- ruby -*-

require 'system/command'
# require 'pvn/diff'

module PVN
  class DescribeCommand < Command
    COMMAND = "describe"

    self.doc do |doc|
      doc.subcommands = [ COMMAND, 'desc' ]
      doc.description = "Describes the changes of one or more revisions."
      doc.usage       =  "[OPTIONS] FILE..."
      doc.summary     = [ "  Prints the log message and the files changed for the given",
                          "  revisions." ]
      doc.examples   << [ "pvn describe -1 foo.rb", "Prints the summary for the most recent revision of foo.rb." ]
    end
    
    # has_option :limit, '-l', "the number of log entries", DEFAULT_LIMIT, :negate => [ %r{^--no-?limit} ]
    has_revision_option :multiple => true

    def initialize args = Hash.new
      info "args: #{args}".on_blue
      super
    end

    def run args
      info "args: #{args}".on_yellow
      revisions = find_option(:revision).value

      info "revisions: #{revisions}".yellow

      revisions.each do |rev|
        info "svn log -r #{rev}"
        info "svn diff --summarize -c #{rev}"
      end
    end
  end
end
