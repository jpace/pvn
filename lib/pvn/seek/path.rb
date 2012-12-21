#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/cat/command'
require 'pvn/log/entries'
require 'riel/log/loggable'

module PVN::Seek
  class Match
    attr_reader :index
    attr_reader :lnum
    attr_reader :line
    attr_reader :entry
    attr_reader :current_entry
    attr_reader :previous_entry
    
    def initialize index, lnum, line, current_entry
      @index = index
      @lnum = lnum
      @line = line
      @entry = current_entry
      @current_entry = current_entry
      @previous_entry = previous_entry
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

    def matches? entry
      contents = cat entry.revision
      contents.each_with_index do |line, lnum|
        if line.index @pattern
          info "line: #{line}".color(:red)
          return { :entry => entry, :lnum => lnum, :line => line }
        end
      end
      nil
    end

    def seek
      latest_match = nil
      
      (0 ... @entries.size).each do |idx|
        entry = @entries[idx]
        current_match = matches? entry
        
        if idx == 0
          latest_match = current_match
          next
        end

        info "idx: #{idx}; entry: #{entry}"
        info "current_match: #{current_match}"
        info "latest_match: #{latest_match}"

        if matchref = process_match(latest_match, current_match)
          info "matchref: #{matchref.inspect}".color("449922")
          return Match.new idx - 1, matchref[:lnum], matchref[:line], matchref[:entry]
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

    def show_entry use_color, ref
      fromrev = @entries[ref.index + 1].revision
      torev   = @entries[ref.index].revision

      pathstr, fromrevstr, torevstr, linestr = if use_color
                                                 [ @path.to_s.color(:yellow), fromrev.color(:magenta), torev.color(:green), ref.line.chomp.bright ]
                                               else
                                                 [ @path.to_s, fromrev, torev, ref.line.chomp ]
                                               end
      
      pathrev = "#{pathstr} -r#{fromrevstr}:#{torevstr}"
      line = "#{ref.lnum + 1}: #{linestr}"
      
      $io.puts pathrev
      $io.puts line
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
      ref = @seeker.seek

      if ref
        # todo: use previous or current entry, and run through entry formatter in log:
        log ref.entry.inspect.color(:red)
        show_entry use_color, ref
      else
        msg = type == :added ? "not found" : "not removed"
        fromrev = @entries[-1].revision
        torev = @entries[0].revision
        $io.puts "#{msg} in revisions: #{fromrev} .. #{torev}"
      end
    end
  end
end
