#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/command/command'
require 'pvn/wordcount'
require 'pvn/io'

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
    REVISION_ARG = '-r'

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

      totalwc = WordCount.new :name => "total"

      files.sort.each do |file|
        filewc = WordCount.new :local => IO::numlines(file), :name => file
        
        cmd = to_command "cat", file
        ::IO.popen cmd do |io|
          filewc.svn = IO::numlines io
          info "filewc: #{filewc.inspect}"
        end

        filewc.write

        totalwc += filewc
        info "totalwc: #{totalwc.inspect}"
      end

      if files.size > 1
        totalwc.write
      end
    end

    def to_command subcmd, *args
      cmd = "svn #{subcmd}"
      info "cmd: #{cmd}".on_blue
      info "args: #{args}".on_blue
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
      info "svnname: #{svnname}".bold

      svninfo = %x{svn info}
      info "svninfo: #{svninfo}".on_black

      svninfo = %x{svn info #{svnname}}
      info "svninfo: #{svninfo}".on_black
    end

    def get_changed_files_revision filespec
      lc = LogCommand.new :revision => @options.revision.value, :verbose => true
      info "lc: #{lc}"
      entry = lc.entries[0]
      return Array.new if entry.nil?

      entry.write

      files = entry.files.collect do |svnfile|
        svn_fullname_to_local_file svnfile
      end
      info "files: #{files}".yellow
      files
    end

    def get_changed_files_wc filespec
      files = Array.new
      cmd = to_command "st", filespec
      ::IO.popen cmd do |io|
        io.each do |line|
          next if line.index %r{^\?}
          pn = Pathname.new line.chomp[8 .. -1]
          files << pn if pn.file?
        end
      end
      files
    end
    
    def get_files fileargs
      info "fileargs: #{fileargs}".yellow

      files = Array.new
      if fileargs.empty?
        files = get_changed_files fileargs
      else
        fileargs.collect do |fn|
          pn = Pathname.new fn
          if pn.directory?
            files.concat get_changed_files(fn)
          else
            files << pn
          end
        end
      end
      files
    end
  end
end
