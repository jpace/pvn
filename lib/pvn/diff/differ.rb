#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pathname'
require 'pvn/config'

module PVN
  # the app for svn --diff-cmd
  class Differ
    include Loggable
    
    def initialize args
      fromlabel = args[2]
      tolabel = args[4]

      fromname, fromrev = fromlabel.split("\t")
      toname, torev = tolabel.split("\t")

      fromfile = args[-2]
      tofile = args[-1]

      diffcmd = diff_command_by_ext fromname

      if diffcmd
        workingcmd = diffcmd.dup

        [ fromlabel, tolabel, fromfile, tofile ].each_with_index do |str, idx|
          workingcmd.gsub! Regexp.new('\{' + idx.to_s + '\}'), str
        end

        run_command workingcmd
      else
        run_diff_default fromlabel, tolabel, fromfile, tofile
      end
    end

    def diff_command_by_ext fname
      extname = Pathname.new(fname).extname
      return nil if extname.empty?

      ext = extname[1 .. -1]

      cfg = PVN::Configuration.read

      diffcfg = cfg.section "diff"
      return nil unless diffcfg

      diff_for_ext = diffcfg.assoc(ext)
      diff_for_ext && diff_for_ext[1]
    end

    def run_diff_default fromfname, tofname, fromfile, tofile
      cmd = "diff -u --label \"#{fromfname}\" --label \"#{tofname}\" #{fromfile} #{tofile}"
      run_command cmd
    end

    def run_command cmd
      info "cmd: #{cmd}".red
      IO.popen(cmd) do |io|
        io.each do |line|
          puts line
        end
      end        
    end
  end
end
