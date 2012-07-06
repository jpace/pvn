#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'svnx/log/entries'

RIEL::Log.level = RIEL::Log::WARN
RIEL::Log.set_widths(-15, 5, -35)

module PVN
  module App
    module Log
      # a format for log entries
      class Format
        include Loggable

        REVISION_WIDTH = 10
        NEG_REVISION_WIDTH = 5
        POS_REVISION_WIDTH = 5
        AUTHOR_WIDTH = 25

        def pad what, width
          " " * (width - what.length)
        end
        
        def format entry, idx, total
          if false
            info "entry.revision: #{entry.revision}"
            info "entry.author  : #{entry.author}"
            info "entry.date    : #{entry.date}"
            info "entry.message : #{entry.message}"
            entry.paths.each do |path|
              info "    path.kind  : #{path.kind}"
              info "    path.action: #{path.action}"
              info "    path.name  : #{path.name}"
            end
          end
          
          lines = Array.new
          
          summary = entry.revision.yellow.dup
          summary << pad(entry.revision, REVISION_WIDTH)

          negidx = (-1 - idx).to_s
          posidx = "+#{total - idx - 1}"

          summary << negidx.bold
          summary << pad(negidx, NEG_REVISION_WIDTH)
          summary << posidx.bold
          summary << pad(posidx, POS_REVISION_WIDTH)
          
          summary << entry.author.cyan
          summary << pad(entry.author, AUTHOR_WIDTH)
          summary << entry.date.magenta

          lines << summary
          lines << ""
          
          lines << entry.message.bold.yellow.on_black
          lines << ""

          entry.paths.each do |path|
            pstr = "    "
            case path.action
            when 'M'
              pstr << path.name.yellow
            when 'A'
              pstr << path.name.green
            when 'D'
              pstr << path.name.red
            when 'R'
              pstr << path.name.magenta
            else
              raise "wtf?: #{path.action}"
            end

            if path.kind == 'dir'
              pstr = pstr.bold
            end

            lines << pstr
          end
          
          lines
        end
      end
    end
  end
end
