#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/util'
require 'pvn/command/cachecmd'
require 'pvn/config'

require 'pvn/subcmd/scexec'
require 'pvn/subcmd/scdoc'
require 'pvn/subcmd/scoptions'
require 'pvn/subcmd/command'

require 'pvn/svn/command/svncmd'

require 'pvn/diff/diffopts'

module PVN  
  class DiffCommand < SVNCommand
    COMMAND = "diff"

    attr_reader :options
    
    self.doc do |doc|
      doc.subcommands = [ COMMAND ]
      doc.description = "Displays differences between revisions."
      doc.usage       = "[OPTIONS] FILE..."
      doc.summary     = [ "Compare two revisions, filtering through external programs.",
                          "For each file compared, the file extension is used to find",
                          "a diff program." ]
      doc.options.concat DiffOptionSet.new.options
      doc.examples   << [ "pvn diff foo.rb", "Compares foo.rb against the last updated version." ]
      doc.examples   << [ "pvn diff -3 StringExt.java", "Compares StringExt.java at change (HEAD - 3), using a Java-specific program such as DiffJ." ]
      doc.examples   << [ "pvn diff -r +4 -w", "Compares the 4th revision against the working copy, ignoring whitespace." ]
    end
    
    def initialize args = Hash.new
      @options = DiffOptionSet.new
      debug "args: #{args.inspect}".yellow

      super
    end

    def use_cache?
      super && !against_head?
    end

    def against_head?
      @options.change.value.nil? && @options.revision.head?
    end
    
    # @todo implement
    if true
      self.options do |opts|
        # opts.add :diffcmd
      end
    end
  end
end
