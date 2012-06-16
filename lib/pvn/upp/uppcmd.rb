#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/command/command'
require 'pvn/base/io'

module PVN
  class UppOptionSet < OptionSet
    attr_accessor :revision
    
    def initialize
      super
      # @revision = add RevisionOption.new
    end
  end

  class UppCommand < Command
    DEFAULT_LIMIT = 5
    COMMAND = "upp"

    self.doc do |doc|
      doc.subcommands = [ COMMAND ]
      doc.description = "Updates the local repository, in parallel for speed."
      doc.usage       = ""
      doc.summary     = [ "Updates the local repository, using parallel tasks. This is",
                          "signficantly faster () for projects with multiple",
                          "subprojects defined as externals." ]
      doc.examples   << [ "pvn upp", "Updates the local repository." ]
    end

    def initialize args
      # insanely simple

      externals = get_all_externals

      upcmds = Array.new
      externals.each do |ext|
        puts "ext: #{ext}"
        upcmds << "cd #{ext} && svn up 2>&1"
      end

      upcmds << "svn up --ignore-externals . 2>&1"
      
      cmds_to_threads = upcmds.map do |upcmd|
        thr = Thread.new do
          IO.popen(upcmd) do |io|
            io.readlines
          end
        end
        [ upcmd, thr ]
      end

      cmds_to_threads.each do |cmd, thread|
        puts cmd
        puts thread.value
      end
    end

    def external_to_local fd, line
      # spaces?
      local, url = line.split

      # I've seen externals defined "backwards" (local url)
      if local.index(%r{\w+://})
        url, local = local, url
      end

      fd + "/" + local
    end

    def get_externals fd
      externals = Array.new
      pgcmd = "svn pg #{fd}"
      IO.popen(pgcmd) do |io|
        io.each do |line|
          next if line.strip.empty?
          
          # spaces?
          local, url = line.split

          # I've seen externals defined "backwards" (local url)
          if local.index(%r{\w+://})
            url, local = local, url
          end

          externals << "#{fd}/#{local}"
        end
      end

      externals
    end

    def get_all_externals
      externals = Array.new

      # get properties list (this could probably be cached, but it's relatively fast)
      proplistcmd = "svn pl -R"
      fd = nil
      fdre = Regexp.new '^Properties on \'(.*)\':$'
      extre = Regexp.new '^\s*svn:externals$'
      IO.popen(proplistcmd) do |io|
        io.each do |line|
          if md = fdre.match(line)
            fd = md[1]
          elsif fd && extre.match(line)
            externals.concat get_externals(fd)
          end
        end
      end
      externals
    end
  end
end
