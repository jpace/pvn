#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/command/command'
require 'pvn/linecount'
require 'pvn/io'
require 'pvn/io/fselement'
require 'pvn/svn/svnelement'
require 'pvn/svn/svnroot'
require 'pvn/io/element'
require 'pvn/file'

module PVN
  class PctOptionSet < OptionSet
    attr_accessor :revision
    
    def initialize
      super
      @revision = add RevisionOption.new
    end
  end

  class PctCommand < Command
    DEFAULT_LIMIT = 5
    COMMAND = "pct"

    self.doc do |doc|
      doc.subcommands = [ COMMAND ]
      doc.description = "Print the comparison of size of locally-changed files."
      doc.usage       = "[OPTIONS] FILE..."
      doc.summary     = [ "Prints the changes in the size (length) of files that have ",
                          "been changed locally, to show the extent to which they have",
                          "increased or decreased. The columns are:",
                          " - length in svn repository",
                          " - length in local version",
                          " - difference",
                          " - percentage change",
                          " - file name",
                          "When more than one file is specified, the total is displayed",
                          "as the last line." ]
      doc.examples   << [ "pvn pct main.c", "Prints the number of lines and percentage by which main.c has changed." ]
    end

    def initialize args
      # not calling super, since all of our stuff goes on in this ctor.

      info "args: #{args}".magenta

      @options = PctOptionSet.new

      @options.process self, args, args[:command_args]
      info "args: #{args}".cyan

      files = get_files @options.arguments
      info "files: #{files.inspect}"

      rev = @options.revision.value
      info "rev: #{rev}"
      
      @output = Array.new

      totallc = LineCount.new :name => "total"

      files.sort.each do |file|
        info "file: #{file}"

        fromlc, tolc = if rev
                         [ file.svn.line_count(rev - 1), file.svn.line_count(rev) ]
                       else
                         [ file.svn.line_count(rev), file.local.line_count ]
                       end

        info "fromlc: #{fromlc}"
        info "tolc: #{tolc}"
        
        filelc = LineCount.new :from => fromlc, :to => tolc, :name => file.local.name
        filelc.write

        totallc += filelc
        info "totallc: #{totallc.inspect}"
      end

      if files.size > 1
        totallc.write
      end
    end

    def to_command subcmd, *args
      cmd = "svn #{subcmd}"
      info "cmd: #{cmd}"
      info "args: #{args}"
      args = args.flatten

      revcl = @options.revision.to_command_line
      if revcl
        cmd << " " << revcl.join(" ")
      end
      cmd << " " << Util::quote_list(args)
      info "cmd: #{cmd}".on_blue
      cmd
    end

    def get_changed_files filespec
      rev = @options.revision.value
      info "rev: #{rev}"
      
      if rev
        get_changed_files_revision filespec
      else
        get_changed_files_wc filespec
      end
    end

    def svn_fullname_to_local_file svnname
      svnroot = SVNRootElement.new
      info "svnroot       : #{svnroot}"
      
      here = SVNElement.new :name => '.'

      hereinfo    = here.info
      info "hereinfo[:url]: #{hereinfo[:url]}"
      reporoot    = hereinfo[:repository_root]

      info "reporoot      : #{reporoot}"

      localname   = svnroot.to_s + svnname
      info "localname     : #{localname}"

      localname
    end

    def get_changed_files_revision filespec
      lc = LogCommand.new :revision => @options.revision.value, :verbose => true
      info "lc: #{lc}"
      entry = lc.entries[0]
      return Array.new if entry.nil?

      entry.write

      files = entry.files.collect do |svnfile|
        localfile = svn_fullname_to_local_file svnfile
        Element.new :file => localfile
      end
      info "files: #{files}".yellow
      files
    end

    def get_changed_files_wc filespec
      files = Array.new
      cmd = to_command "st", filespec
      IO.popen cmd do |io|
        io.each do |line|
          next if line.index %r{^\?}
          pn = Element.new :file => line.chomp[8 .. -1]
          files << pn if pn.local.file?
        end
      end
      info "files: #{files}".red
      files
    end
    
    def get_files fileargs
      info "fileargs: #{fileargs}".yellow

      files = Array.new
      if fileargs.empty?
        files = get_changed_files fileargs
      else
        fileargs.collect do |fn|
          elmt = Element.new :file => fn
          if elmt.local.directory?
            files.concat get_changed_files(fn)
          else
            files << elmt
          end
        end
      end

      info "files: #{files}".yellow

      files
    end
  end
end
