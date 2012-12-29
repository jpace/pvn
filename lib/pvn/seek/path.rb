#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/cat/command'
require 'pvn/log/entries'
require 'riel/log/loggable'

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
      [ path.to_s.color(:yellow), fromrev.color(:magenta), torev.color(:green), line.chomp.bright ]
    end
    
    def show path, use_color
      fromrev = current_entry.revision
      torev   = previous_entry.revision

      pathstr, fromrevstr, torevstr, linestr = use_color ? decorate(path, fromrev, torev) : [ path.to_s, fromrev, torev, line.chomp ]
      
      pathrev = "#{pathstr} -r#{fromrevstr}:#{torevstr}"
      line = "#{lnum + 1}: #{linestr}"
      
      $io.puts pathrev
      $io.puts line
    end

    def to_s
      "[#{lnum}]: #{line.chomp}; #{previous_entry.revision}; #{current_entry.revision}"
    end

    def orig_diff othermatch
      otherlines = othermatch.lines
      currlines = lines

      info "otherlines: <<<#{otherlines}>>>".color("8a9acc")
      info "currlines: <<<#{currlines}>>>".color("8a9acc")

      difflines = currlines - otherlines
      info "difflines: #{difflines}".color("cc33ff")
      difflines
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
      matchlnums = (0 ... contents.length).select do |lnum|
        contents[lnum].index @pattern
      end
      return if matchlnums.empty?
      matchlnum = matchlnums[0]
      Match.new(matchlnums, contents, previous_entry, current_entry)
    end

    def seek
      latest_match = nil
      
      (0 ... @entries.size).each do |idx|
        entry = @entries[idx]
        info "entry.revision: #{entry.revision}"
        current_match = matches? @entries[idx - 1], entry
        
        if idx == 0
          latest_match = current_match
          next
        end

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

  # class SeekerAdded < Seeker
  #   def process_match prevmatch, currmatch
  #     return if currmatch.nil? && prevmatch.nil?
  #     info "prevmatch.lnums: #{prevmatch && prevmatch.lnums.inspect}".color("8a9a33")
  #     info "currmatch.lnums: #{currmatch && currmatch.lnums.inspect}".color("8a9a33")
  #     return prevmatch if !currmatch && prevmatch
  #     difflines = currmatch.diff prevmatch
  #     return if difflines.empty?
  #     info "difflines: #{difflines}".color("cc33ff")
  #     Match.new difflines.collect { |x| x[0] }, currmatch.contents, prevmatch.previous_entry, currmatch.current_entry
  #     nil
  #   end
  # end

  class SeekerAdded < Seeker
    def process_match prevmatch, currmatch
      !currmatch && prevmatch
    end
  end

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

    def seek type, pattern, revision, use_color
      rev = if revision
              if revision.size == 1
                [ revision[0], 'HEAD' ].join(':')
              else
                revision.join(':')
              end
            else
              nil
            end
      
      logentries = PVN::Log::Entries.new @path, PathLogOptions.new(rev)
      @entries = logentries.entries
      
      seekcls = type == :added ? SeekerAdded : SeekerRemoved
      @seeker = seekcls.new @path, pattern, revision, @entries
      match = @seeker.seek

      if match
        # todo: use previous or current entry, and run through entry formatter in log:
        match.show @path, use_color
      else
        msg = type == :added ? "not found" : "not removed"
        fromrev = @entries[-1].revision
        torev = @entries[0].revision
        $io.puts "#{msg} in revisions: #{fromrev} .. #{torev}"
      end
    end
  end
end
