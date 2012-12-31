#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'rubygems/text'

module PVN; module Command; end; end

module PVN::Command
  class Documentation
    include Gem::Text

    SUMMARY_RE = Regexp.new '^(?:(.*)(?:NOWRAP(.*)/NOWRAP)|(.*))(.*)$', Regexp::MULTILINE
    
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

    def wrap out, str
      # I could use tput cols; ENV['COLUMNS'] works in irb, not in Ruby scripts.
      out.puts format_text str.gsub("\n", ''), 78, 2
    end

    def write_summary out
      summary.join("\n").scan(SUMMARY_RE) do |md|
        if md[2]
          wrap out, md[2]
          next
        end

        wrap out, md[0]
        out.puts md[1].collect { |x| "  " + x }
        
        out.puts
        wrap out, md[3]
      end
    end

    def write out = $io
      doc = Array.new

      subcmds = @subcommands

      subcmdstr = subcmds[0].dup
      if subcmds.size > 1
        subcmdstr << " (" << subcmds[1 .. -1].join(" ") << ")"
      end

      out.puts subcmdstr + ": " + @description
      out.puts "usage: " + subcmds[0] + " " + @usage
      out.puts ""
      write_summary out
      
      write_section "options", @options, out do |opt, io|
        option_to_doc opt, io
      end

      write_section "examples", @examples, out do |ex, io|
        example_to_doc ex, io
      end
    end

    def write_section name, section, out
      if section.length > 0
        out.puts ""
        out.puts "#{name.capitalize}:"
        out.puts ""
        
        section.each do |opt|
          yield opt, out
        end
      end
    end

    def example_to_doc ex, out
      ex.each_with_index do |line, idx|
        if idx == 0
          out.puts "  % #{line}"
        else
          out.puts "    #{line}"
        end
      end
      out.puts
    end

    def option_to_doc opt, out
      opt.to_doc out
    end
  end
end
