#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/command'
# require 'pvn/diff'

module PVN
  class DescribeCommand < Command
    COMMAND = "describe"

    subcommands [ COMMAND, 'desc' ]
    description "Describes the changes of one or more revisions."
    usage "[OPTIONS] FILE..."
    summary [ "  Prints the log message and the files changed for the given",
              "  revisions." ]
    
    examples << [ "pvn describe -1 foo.rb", "Prints the summary for the most recent revision of foo.rb." ]
    
    # has_option :limit, '-l', "the number of log entries", :default => DEFAULT_LIMIT, :negate => [ %r{^--no-?limit} ]
    has_revision_option :multiple => true

    def initialize args = Hash.new
      info "args: #{args}".on_blue
      super
    end

    def run args
      info "args: #{args}".on_yellow
      revisions = find_option(:revision).value
      info "args: #{args}".on_yellow

      info "revisions: #{revisions}".yellow

      revisions.each do |rev|
        info "svn log -r #{rev}"
        info "svn diff --summarize -c #{rev}"
      end
    end
  end
end
