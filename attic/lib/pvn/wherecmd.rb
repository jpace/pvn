#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'system/command'
require 'pvn/io/fselement'
# require 'pvn/svn/svnelement'
# require 'pvn/svn/svnroot'
require 'pvn/io/element'

module PVN
  class WhereOptionSet < OptionSet
    attr_accessor :revision
    
    def initialize
      super
      # @revision = add RevisionRegexpOption.new
    end
  end

  class WhereCommand < Command
    DEFAULT_LIMIT = 5
    COMMAND = "where"

    self.doc do |doc|
      doc.subcommands = [ COMMAND ]
      doc.description = "Shows the Subversion mapping from the given URL or file."
      doc.usage       = "[OPTIONS] [FILE|URL]..."
      doc.summary     = [ "Shows the Subversion mapping from the URL or file. If the ",
                          "argument is a URL, then the local file/directory is displayed.",
                          "If the argument is a file, then the URL for the Subversion",
                          "repository is printed." ]
      # doc.examples   << [ "pvn pct main.c", "Prints the number of lines and percentage by which main.c has changed." ]
    end

    def initialize args
      # not calling super, since all of our stuff goes on in this ctor.

      args[:command_args].each do |arg|
        info "arg: #{arg}".on_black

        if arg.index(%r{^\w+:\/\/})
          info "url: #{arg}".on_red
        else
          info "file: #{arg}".red
          el = Element.new :file => arg
          info "el: #{el}"
          info "el.local: #{el.local}"
          info "el.svn: #{el.svn}"
        end
      end
    end
  end
end
