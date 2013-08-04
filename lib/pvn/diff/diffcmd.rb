#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'

# the command-line diff program.
module PVN::Diff
  class Cmd
    include Logue::Loggable

    def initialize displaypath, fromrev, torev, fromlines, tolines, whitespace
      open_temp_file(fromlines) do |from|
        open_temp_file(tolines) do |to|
          cmd = "diff -u"
          if whitespace
            cmd << " -w"
          end

          [ fromrev, torev ].each do |rev|
            revstr = to_revision_string rev
            cmd << " -L '#{displaypath}\t(#{revstr})'"
          end
          cmd << " #{from.path}"
          cmd << " #{to.path}"

          info "cmd: #{cmd}"

          $io.puts "Index: #{displaypath}"
          $io.puts "==================================================================="
          IO.popen(cmd) do |io|
            $io.puts io.readlines
          end
        end
      end
    end

    def open_temp_file lines, &blk
      Tempfile.open('pvn') do |tmpfile|
        if lines
          tmpfile.puts lines
        end
        tmpfile.close

        blk.call tmpfile
      end
    end

    def to_revision_string rev
      rev ? "revision #{rev}" : "working copy"
    end
  end
end
