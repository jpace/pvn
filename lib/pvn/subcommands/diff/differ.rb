#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/subcommands/diff/options'
require 'pvn/subcommands/base/command'
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
        info "topath: #{topath}"
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
      info "whitespace: #{whitespace}"
      
      cmd = "diff -u"
      if whitespace
        cmd << " -x -b -x -w -x --ignore-eol-style"
      end

      [ fromrev, torev ].each do |rev|
        revstr = to_revision_string rev
        info "revstr: #{revstr}".yellow
        cmd << " -L '#{displaypath}\t(#{revstr})'"
      end
      cmd << " #{frompath}"
      cmd << " #{topath}"
      $io.puts "Index: #{displaypath}"
      $io.puts "==================================================================="
      IO.popen(cmd) do |io|
        $io.puts io.readlines
      end
    end
  end
end
