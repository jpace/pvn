#!/usr/bin/ruby -w
# -*- ruby -*-

require 'riel/log/loggable'

# the command-line diff program.
module PVN::Diff
  class Cmd
    include RIEL::Loggable

    def initialize displaypath, fromrev, torev, frompath, topath, whitespace
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

    def to_revision_string rev
      rev ? "revision #{rev}" : "working copy"
    end
  end
end
