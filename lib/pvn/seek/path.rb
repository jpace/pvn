#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/cat/command'
require 'pvn/log/entries'
require 'riel/log/loggable'

module PVN::Seek
  class Match
    attr_reader :lnum
    attr_reader :contents
    attr_reader :current_entry
    attr_reader :previous_entry
    
    def initialize lnum, contents, previous_entry, current_entry
      @lnum = lnum
      @contents = contents
      @previous_entry = previous_entry
      @current_entry = current_entry
    end

    def line
      @contents[lnum]
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
      "[#{lnum}]: #{line.chomp}; #{previous_entry}; #{current_entry}"
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
      info "path: #{@path}"
      info "revision: #{revision}"
      catargs = SVNx::CatCommandArgs.new :path => @path, :use_cache => true, :revision => revision
      cmd = SVNx::CatCommand.new catargs
      cmd.execute
    end

    def matches? previous_entry, current_entry
      contents = cat current_entry.revision
      matchlnums = (0 ... contents.length).select do |lnum|
        if contents[lnum].index @pattern
          info "lnum: #{lnum}".color("994a9a")
          info "contents[lnum]: #{contents[lnum]}".color("9a449a")
        end

        contents[lnum].index @pattern
      end
      return if matchlnums.empty?
      info "matchlnums: #{matchlnums.inspect}".color("bb9a8c")
      matchlnum = matchlnums[0]
      begin 
        info "matchlnum: #{matchlnum}".color("994a9a")
        info "contents[matchlnum]: #{contents[matchlnum]}".color("994a9a")
        Match.new(matchlnum, contents, previous_entry, current_entry)
      end
    end

    def seek
      latest_match = nil
      
      (0 ... @entries.size).each do |idx|
        entry = @entries[idx]
        current_match = matches? @entries[idx - 1], entry
        
        if idx == 0
          latest_match = current_match
          next
        end

        info "idx: #{idx}; entry: #{entry}"
        info "current_match: #{current_match}"
        info "latest_match: #{latest_match}"

        if matchref = process_match(latest_match, current_match)
          info "matchref: #{matchref.inspect}".color("449922")
          return Match.new matchref.lnum, matchref.contents, @entries[idx - 1], entry
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
    def process_match preventry, currentry
      !currentry && preventry
    end
  end

  class SeekerRemoved < Seeker
    def process_match preventry, currentry
      !preventry && currentry
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
      @entries.each do |entry|
        info "entry: #{entry}".color("98aacc")
      end
      
      seekcls = type == :added ? SeekerAdded : SeekerRemoved
      @seeker = seekcls.new @path, pattern, revision, @entries
      match = @seeker.seek

      if match
        # todo: use previous or current entry, and run through entry formatter in log:
        log match.current_entry.inspect.color(:red)
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
