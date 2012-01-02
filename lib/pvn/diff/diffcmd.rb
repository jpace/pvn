#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/util'
require 'pvn/command/cachecmd'
require 'pvn/config'

require 'pvn/subcmd/scexec'
require 'pvn/subcmd/scdoc'
require 'pvn/subcmd/scoptions'
require 'pvn/subcmd/command'

require 'pvn/command/svncmd'

require 'pvn/diff/diffopts'

module PVN  
  class DiffCommand < SVNCommand
    COMMAND = "diff"

    attr_reader :options
    
    self.doc do |doc|
      doc.subcommands = [ COMMAND ]
      doc.description = "Displays differences between revisions."
      doc.usage       = "[OPTIONS] FILE..."
      doc.summary     = [ "Compare two revisions, filtering through" ]
      doc.examples   << [ "pvn diff foo.rb", "Compares foo.rb against the last updated version." ]
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
