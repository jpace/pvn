#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/log/entries'
require 'riel/log/loggable'
require 'svnx/exec'
require 'pvn/seek/match'

module PVN::Seek
  class Seeker
    include RIEL::Loggable

    def initialize path, pattern, revision, entries
      @path = path
      @pattern = pattern
      @revision = revision
      @entries = entries
    end

    def cat revision
      ex = SVNx::Exec.new
      ex.cat @path, revision, true
    end

    def matches? previous_entry, current_entry
      contents = cat current_entry.revision
      contents.collect! { |x| x.chomp! }
      matchlnums = (0 ... contents.length).select do |lnum|
        contents[lnum].index @pattern
      end
      return if matchlnums.empty?
      Match.new matchlnums, contents, previous_entry, current_entry
    end

    def match idx
      entry = @entries[idx]
      preventry = idx > 0 ? @entries[idx - 1] : nil
      matches? preventry, entry
    end
    
    def seek
      latest_match = match 0
      
      (1 ... @entries.size).each do |idx|
        entry = @entries[idx]
        current_match = match idx

        if matchref = process_match(latest_match, current_match)
          return Match.new matchref.lnums, matchref.contents, @entries[idx - 1], entry
        end
        
        if current_match
          latest_match = current_match
        end
      end
      nil
    end

    def full_diff? ifmatch, ifnomatch
      return ifmatch if !ifnomatch
    end

    def process_match ifmatch, ifnomatch, prevmatch, currmatch
      return unless ifmatch
      return ifmatch if full_diff? ifmatch, ifnomatch
      diff_match ifmatch, ifnomatch, prevmatch, currmatch
    end

    def diff_match ifmatch, ifnomatch, prevmatch, currmatch
      difflines = ifmatch.diff ifnomatch
      return if difflines.empty?
      info "difflines: #{difflines}".color("cc33ff")
      Match.new difflines.collect { |x| x[0] }, ifmatch.contents, prevmatch.previous_entry, currmatch.current_entry
    end
  end

  class SeekerAdded < Seeker
    def process_match prevmatch, currmatch
      super prevmatch, currmatch, prevmatch, currmatch
    end
  end

  class SeekerRemoved < Seeker
    def process_match prevmatch, currmatch
      super currmatch, prevmatch, prevmatch, currmatch
    end
  end
end
