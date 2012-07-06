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

        WIDTHS = { 
          :revision => 10, 
          :neg_revision => 5,
          :pos_revision => 5,
          :author => 25
        }

        COLORS = {
          :revision => [ :bold ],
          :neg_revision => [ :bold ],
          :pos_revision => [ :bold ],
          :author => [ :bold, :cyan ],
          :date => [ :bold, :magenta ],

          :added => [ :green ],
          :modified => [ :yellow ],
          :deleted => [ :red ],
          :renamed => [ :magenta ],

          :dir => [ :bold ],
        }

        def pad what, field
          nspaces = [ WIDTHS[field] - what.length, 1 ].max
          " " * nspaces
        end

        def colorize what, field
          colors = COLORS[field]
          colors.each do |col|
            what = what.send col
          end
          what
        end

        def add_field value, field
          colorize(value, field) + pad(value, field)
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
          
          summary = add_field(entry.revision, :revision)

          negidx = (-1 - idx).to_s
          posidx = "+#{total - idx - 1}"

          summary << add_field(negidx, :neg_revision)
          summary << add_field(posidx, :pos_revision)
          
          summary << add_field(entry.author, :author)
          
          summary << colorize(entry.date, :date)

          lines << summary
          lines << ""
          
          lines << entry.message.white.on_black
          lines << ""

          entry.paths.each do |path|
            pstr = "    "
            case path.action
            when 'M'
              pstr << colorize(path.name, :modified)
            when 'A'
              pstr << colorize(path.name, :added)
            when 'D'
              pstr << colorize(path.name, :deleted)
            when 'R'
              pstr << colorize(path.name, :renamed)
            else
              raise "wtf?: #{path.action}"
            end

            if path.kind == 'dir'
              pstr = colorize(pstr, :dir)
            end

            lines << pstr
          end
          
          lines
        end
      end
    end
  end
end
