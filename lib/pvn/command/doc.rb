#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

module PVN; module Command; end; end

# this is the same as in pvn/cmddoc.rb

module PVN::Command
  class Documentation
    attr_accessor :description
    attr_accessor :usage
    attr_accessor :summary
    
    attr_reader :examples
    attr_reader :options

    def initialize(&blk)
      @subcommands = nil
      @description = nil
      @usage = nil
      @summary = nil
      @options = Array.new
      @examples = Array.new
      if blk
        blk.call
      end
    end

    def subcommands args = nil
      if args
        @subcommands = args
      end
      @subcommands
    end

    def subcommands= args
      @subcommands = args
    end

    def write io = $stdout
      doc = Array.new

      subcmds = @subcommands

      subcmdstr = subcmds[0].dup
      if subcmds.size > 1
        subcmdstr << " (" << subcmds[1 .. -1].join(" ") << ")"
      end

      io.puts subcmdstr + ": " + @description
      io.puts "usage: " + subcmds[0] + " " + @usage
      io.puts ""
      io.puts @summary.collect { |line| "  " + line }

      write_section "options", @options, io do |opt, io|
        option_to_doc opt, io
      end

      write_section "examples", @examples, io do |ex, io|
        example_to_doc ex, io
      end
    end

    def write_section name, section, io
      if section.length > 0
        io.puts ""
        io.puts "#{name.capitalize}:"
        io.puts ""
        
        section.each do |opt|
          yield opt, io
        end
      end
    end

    def example_to_doc ex, io
      ex.each_with_index do |line, idx|
        if idx == 0
          io.puts "  % #{line}"
        else
          io.puts "    #{line}"
        end
      end
      io.puts
    end

    def option_to_doc opt, io
      opt.to_doc io
    end
  end
end
