#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/revision'

module PVN::Subcommands::Diff
  # represents the log entries from one revision through another.
  class LogPaths
    include Loggable

    attr_reader :entries

    def initialize revision, paths
      @revision = revision
      
      # maps by log path to log entries
      @entries = Hash.new { |h, k| h[k] = Hash.new }

      paths.each do |path|
        info "path: #{path}"
        pathelmt = PVN::IO::Element.new :local => path
        pathinfo = pathelmt.get_info
        info "pathinfo: #{pathinfo.inspect}".on_black

        elmt = PVN::IO::Element.new :local => path
        logentries = elmt.logentries @revision

        logentries.each do |logentry|
          logentry.paths.each do |lp|
            next if lp.kind != 'file'
            info "lp: #{lp}".red
            @entries[lp.name][logentry.revision] = [ lp, pathinfo ]
          end 
        end
      end
      info "@entries: #{@entries}".cyan
      
      # require 'pp'
      # pp @entries

      @entries
    end
  end
end

