#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'pvn/log/entries'
require 'pvn/seek/seeker'

module PVN::Seek
  class Path
    include Logue::Loggable

    def initialize path
      @path = path
    end

    def to_revision_arg revision
      return unless revision
      if revision.size == 1
        [ revision[0], 'HEAD' ].join(':')
      else
        revision.join ':'
      end
    end

    def get_entries revision
      logentries = PVN::Log::Entries.new @path, revision: revision, files: nil, use_cache: nil, limit: nil
      logentries.to_a
    end

    def show_no_match type, entries
      msg = type == :added ? "not found" : "not removed"
      fromrev = entries[-1].revision
      torev = entries[0].revision
      $io.puts "#{msg} in revisions: #{fromrev} .. #{torev}"
    end

    def get_seek_class type
      type == :added ? SeekerAdded : SeekerRemoved
    end
    
    def seek type, pattern, revision, use_color
      entries = get_entries revision
      
      seekcls = get_seek_class type
      @seeker = seekcls.new @path, pattern, revision, entries
      
      if match = @seeker.seek
        match.show @path, use_color
      else
        show_no_match type, entries
      end
    end
  end
end
