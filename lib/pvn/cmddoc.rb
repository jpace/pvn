#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

module PVN
  class CommandDoc
    attr_accessor :subcommands
    attr_accessor :description
    attr_accessor :usage
    attr_accessor :summary
    
    attr_reader :examples
    attr_reader :options

    def initialize
      @subcommands = nil
      @description = nil
      @usage = nil
      @summary = nil
      @options = Array.new
      @examples = Array.new
    end

    def to_doc io = $stdout
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
      opttag  = opt.tag
      optdesc = opt.description
      
      RIEL::Log.debug "opttag: #{opttag}"
      RIEL::Log.debug "optdesc: #{optdesc}"

      # wrap optdesc?
      
      optdesc.each_with_index do |descline, idx|
        lhs = if idx == 0
                sprintf("%-24s :", opttag)
              else
                " " * 26
              end
        optstr = sprintf "  %4s %s", lhs, descline
        
        io.puts optstr
      end
    end
  end
end