#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/diff/options'
require 'pvn/command/command'
require 'tempfile'

$io = $stdout

module PVN::Subcommands::Diff
  class Differ
    include Loggable

    attr_reader :whitespace
    attr_reader :revision
    
    def initialize options
    end

    def to_revision_string rev
      rev ? "revision #{rev}" : "working copy"
    end

    def write_to_temp entry, lines
      Tempfile.open('pvn') do |to|
        topath = to.path
        to.puts lines
        to.close
        cmd = "diff -u"
        label = " -L '#{entry.path} (revision 0)'"
        2.times do
          cmd << label
        end
        cmd << " #{frpath}"
        cmd << " #{entry.path}"
        IO.popen(cmd) do |io|
          puts io.readlines
        end
      end
    end

    def run_diff_command displaypath, fromrev, torev, frompath, topath
      cmd = "diff -u"
      if whitespace
        cmd << " -w"
      end

      [ fromrev, torev ].each do |rev|
        revstr = to_revision_string rev
        cmd << " -L '#{displaypath}\t(#{revstr})'"
      end
      cmd << " #{frompath}"
      cmd << " #{topath}"

      info "cmd: #{cmd}"

      $io.puts "Index: #{displaypath}"
      $io.puts "==================================================================="
      IO.popen(cmd) do |io|
        $io.puts io.readlines
      end
    end

    def run_diff displaypath, fromlines, fromrev, tolines, torev
      Tempfile.open('pvn') do |from|
        if fromlines
          from.puts fromlines
        end
        from.close

        Tempfile.open('pvn') do |to|
          if tolines
            to.puts tolines
          end
          to.close
          
          run_diff_command displaypath, fromrev, torev, from.path, to.path
        end
      end
    end
  end
end
