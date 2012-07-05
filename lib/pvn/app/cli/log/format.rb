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
        
        def format entry
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
          summary << (" " * (10 - entry.revision.length))
          summary << entry.author.cyan
          summary << (" " * (25 - entry.author.length))
          summary << entry.date.magenta
          # summary << (" " * (40 - entry.date.length))

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
