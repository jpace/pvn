#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/command/command'
require 'pvn/log/logfactory'

module PVN
  class PctOptionSet < OptionSet
    attr_accessor :revision
    
    def initialize
      super

      self << (@revision = RevisionOption.new :unsets => :limit)
    end
  end

  class WordCount
    attr_accessor :local
    attr_accessor :svn

    def initialize args = Hash.new
      @name  = args[:name]  || ""
      @local = args[:local] || 0
      @svn   = args[:svn]   || 0
    end

    def +(other)
      WordCount.new :local => @local + other.local, :svn => @svn + other.svn
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

      optset = PctOptionSet.new

      info "args[:command_args]: #{args[:command_args]}".magenta
      optset.process self, args, args[:command_args]
      info "args[:command_args]: #{args[:command_args]}".magenta
      files = get_files args[:command_args]
      info "files: #{files.inspect}".red
      
      @output = Array.new

      totalwc = WordCount.new :name => "total"

      files.sort.each do |file|
        filewc = WordCount.new :local => numlines(file), :name => file
        info "filewc: #{filewc.inspect}"
        
        IO.popen "svn cat #{file}" do |io|
          filewc.svn = numlines io
          info "filewc: #{filewc.inspect}"
        end

        filewc.write

        totalwc += filewc
        info "totalwc: #{totalwc.inspect}"
      end

      totalwc.write
    end

    def get_files fileargs
      info "fileargs: #{fileargs}".yellow

      files = nil
      if fileargs.empty?
        files = Array.new
        IO.popen "svn st" do |io|
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
            # not handled
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
