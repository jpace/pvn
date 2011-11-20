#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pathname'
require 'pvn/config'

Log.level = Log::DEBUG

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

      cfg = PVN::Configuration.read

      diffcfg = cfg.section "diff"

      ext_to_diffcmd = Hash.new
      diffcfg.each do |dc|
        ext_to_diffcmd[dc[0]] = dc[1]
      end

      extname = Pathname.new(fromname).extname

      if extname.empty?
        run_diff_default fromlabel, tolabel, fromfile, tofile
      elsif cmd = ext_to_diffcmd[extname[1 .. -1]]
        workingcmd = cmd.dup

        [ fromlabel, tolabel, fromfile, tofile ].each_with_index do |str, idx|
          workingcmd.gsub! Regexp.new('\{' + idx.to_s + '\}'), str
        end

        run_command workingcmd
      else
        run_diff_default fromlabel, tolabel, fromfile, tofile
      end
    end

    def run_diff_default fromfname, tofname, fromfile, tofile
      cmd = "diff -u --label \"#{fromfname}\" --label \"#{tofname}\" #{fromfile} #{tofile}"
      run_command cmd
    end

    def run_command cmd
      IO.popen(cmd) do |io|
        io.each do |line|
          puts line
        end
      end        
    end
  end
end
