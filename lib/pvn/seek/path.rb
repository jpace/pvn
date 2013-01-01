#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/cat/command'
require 'pvn/log/entries'
require 'riel/log/loggable'
# require 'riel/array'

module PVN::Seek
  class Match
    include RIEL::Loggable

    attr_reader :lnums
    attr_reader :contents
    attr_reader :current_entry
    attr_reader :previous_entry
    
    def initialize lnums, contents, previous_entry, current_entry
      @lnums = lnums
      @contents = contents
      @previous_entry = previous_entry
      @current_entry = current_entry
    end

    def lnum
      @lnums[0]
    end

    def lines
      @lnums.collect { |lnum| @contents[lnum] }
    end

    def line
      @contents[@lnums[0]]
    end

    def decorate path, fromrev, torev
      [ path.to_s.color(:yellow), fromrev.color(:magenta), torev.color(:green) ]
    end
    
    def show path, use_color
      fromrev = current_entry.revision
      torev   = previous_entry.revision

      info "lines: #{lines}".color("98aacc")

      pathstr, fromrevstr, torevstr = use_color ? decorate(path, fromrev, torev) : [ path.to_s, fromrev, torev ]
      pathrev = "#{pathstr} -r#{fromrevstr}:#{torevstr}"
      $io.puts pathrev
      
      @lnums.each do |lnum|
        line = @contents[lnum]
        linestr = use_color ? line.chomp.bright : line.chomp
        line = "#{lnum + 1}: #{linestr}"
        $io.puts line
      end
    end

    def to_s
      "[#{lnums}]: #{lines}; prev: #{previous_entry && previous_entry.revision}; curr: #{current_entry && current_entry.revision}"
    end

    def has_line? line
      @lnums.detect { |lnum| @contents[lnum].index line }
    end

    def diff othermatch
      info "lines: #{lines}"
      info "othermatch.lines: #{othermatch.lines}"
      otherlnums = othermatch.lnums
      currlnums = lnums

      diff = Array.new
      lnums.each do |lnum|
        line = @contents[lnum]
        info "line: #{line}".color("88CC33")
        unless othermatch.has_line? line
          diff << [ lnum, line ]
          info "diff: #{diff}".color("88CC33")
        end
      end

      info "diff: #{diff}".color("ee3399")
      diff
    end
  end

  class PathLogOptions
    def initialize revision
      @revision = revision
    end

    def limit; nil; end
    def verbose; nil; end
    def revision; @revision; end
    def user; nil; end
    def use_cache; nil; end
    def files; end
  end

  class Seeker
    include RIEL::Loggable

    def initialize path, pattern, revision, entries
      @path = path
      @pattern = pattern
      @revision = revision
      @entries = entries
    end

    def cat revision
      catargs = SVNx::CatCommandArgs.new :path => @path, :use_cache => true, :revision => revision
      cmd = SVNx::CatCommand.new catargs
      cmd.execute
    end

    def matches? previous_entry, current_entry
      contents = cat current_entry.revision
      contents.collect! { |x| x.chomp! }
      matchlnums = (0 ... contents.length).select do |lnum|
        contents[lnum].index @pattern
      end
      return if matchlnums.empty?
      info "matchlnums: #{matchlnums.inspect}".color("33CC22")
      Match.new(matchlnums, contents, previous_entry, current_entry)
    end

    def match idx
      entry = @entries[idx]
      info "entry.revision: #{entry.revision}"
      preventry = idx > 0 ? @entries[idx - 1] : nil
      info "preventry: #{preventry}"
      matches? preventry, entry
    end
    
    def seek
      latest_match = match 0
      
      (1 ... @entries.size).each do |idx|
        entry = @entries[idx]
        info "entry.revision: #{entry.revision}"
        current_match = matches? @entries[idx - 1], entry
        info "current_match: #{current_match}"
        info "latest_match: #{latest_match}"

        if matchref = process_match(latest_match, current_match)
          return Match.new matchref.lnums, matchref.contents, @entries[idx - 1], entry
        end
        
        info "current_match: #{current_match}"

        if current_match
          latest_match = current_match
        end
      end
      nil
    end
  end

  class SeekerAdded < Seeker
    def process_match prevmatch, currmatch
      return unless prevmatch
      info "prevmatch.lnums: #{prevmatch && prevmatch.lnums.inspect}".color("8a9a33")
      info "currmatch.lnums: #{currmatch && currmatch.lnums.inspect}".color("8a9a33")
      return prevmatch if !currmatch
      difflines = prevmatch.diff currmatch
      return if difflines.empty?
      info "difflines: #{difflines}".color("cc33ff")
      Match.new difflines.collect { |x| x[0] }, prevmatch.contents, prevmatch.previous_entry, currmatch.current_entry
    end
  end

  # class SeekerAdded < Seeker
  #   def process_match prevmatch, currmatch
  #     !currmatch && prevmatch
  #   end
  # end

  class SeekerRemoved < Seeker
    def process_match prevmatch, currmatch
      !prevmatch && currmatch
    end
  end

  class Path
    include RIEL::Loggable

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
      rev = to_revision_arg revision      
      logentries = PVN::Log::Entries.new @path, PathLogOptions.new(revision)
      logentries.entries
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
        # todo: use previous or current entry, and run through entry formatter in log:
        match.show @path, use_color
      else
        show_no_match type, entries
      end
    end
  end
end
