#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/command/command'
require 'pvn/log/logfactory'

module PVN
  class PctOptionSet < OptionSet
    attr_accessor :revision
    
    def initialize
      super
      @revision = add RevisionOption.new
    end
  end

  class WordCount
    attr_accessor :local
    attr_accessor :svn
    attr_accessor :name

    def initialize args = Hash.new
      @name  = args[:name]  || ""
      @local = args[:local] || 0
      @svn   = args[:svn]   || 0
    end

    def +(other)
      # the new wc has the name of the lhs of the add:
      WordCount.new :local => @local + other.local, :svn => @svn + other.svn, :name => @name
    end

    def diff
      @local - @svn
    end

    def diffpct
      100.0 * diff / @svn
    end

    def write
      printf "%8d %8d %8d %8.1f%% %s\n", @svn, @local, diff, diffpct, @name
    end
  end

  class PctCommand < Command
    DEFAULT_LIMIT = 5
    COMMAND = "log"
    REVISION_ARG = '-r'

    def initialize args
      # not calling super, since all of our stuff goes on in this ctor.

      info "args: #{args}".magenta

      @options = PctOptionSet.new

      @options.process self, args, args[:command_args]
      files = get_files args[:command_args]
      info "files: #{files.inspect}"

      rev = @options.revision.value
      info "rev: #{rev}"
      
      @output = Array.new

      totalwc = WordCount.new :name => "total"

      files.sort.each do |file|
        filewc = WordCount.new :local => numlines(file), :name => file
        
        cmd = to_command "cat", file
        IO.popen cmd do |io|
          filewc.svn = numlines io
          info "filewc: #{filewc.inspect}"
        end

        filewc.write

        totalwc += filewc
        info "totalwc: #{totalwc.inspect}"
      end

      totalwc.write
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
      cmd << quote_args(args)
      info "cmd: #{cmd}".on_blue
      cmd
    end

    def quote_args args
      str = ""
      if args.length > 0
        args.each do |arg|
          sa = arg.to_s
          if sa.index(' ')
            sa = "\"#{sa}\""
          end
          str << " " << sa
        end
      end
      str
    end
    
    def get_files fileargs
      info "fileargs: #{fileargs}".yellow

      files = nil
      if fileargs.empty?
        files = Array.new

        # if a revision is set, then this should be "log -v" to determine the
        # fileset of that revision.
        cmd = to_command "st", files
        IO.popen cmd do |io|
          io.each do |line|
            next if line.index %r{^\?}
            pn = Pathname.new line.chomp[8 .. -1]
            files << pn if pn.file?
          end
        end
      else
        files = fileargs.collect do |fn|
          pn = Pathname.new fn
          if pn.directory?
            info "not handled: #{pn}".on_red
          else
            pn
          end
        end
      end
      files
    end

    def numlines io
      info "io: #{io}".red
      # info "io.readlines: #{io.readlines}".red
      sz = io.readlines.size
      info "sz: #{sz}".red
      sz
    end
  end
end
