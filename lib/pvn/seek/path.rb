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
    
    def initialize index, lnum, line, entry
      @index = index
      @lnum = lnum
      @line = line
      @entry = entry
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
          return [ entry, lnum, line ]
        end
      end
      nil
    end

    def seek
      criteria = self.criteria
      prevref = nil
      
      (0 ... @entries.size).each do |idx|
        entry = @entries[idx]
        ref = matches? entry

        if idx == 0
          prevref = ref
          next
        end

        info "idx: #{idx}; entry: #{entry}"
        info "ref: #{ref}"
        info "prevref: #{prevref}"

        if matchref = criteria.call(prevref, ref)
          info "matchref: #{matchref.inspect}".background("449922")
          info "matchref: #{matchref[0].inspect}".color("449922")
          info "matchref: #{matchref[1].inspect}".color("449922")
          info "matchref: #{matchref[2].inspect}".color("449922")
          return Match.new idx - 1, matchref[1], matchref[2], matchref[0]
        end
        
        info "ref: #{ref}"

        if ref
          prevref = ref
        end
      end
      nil
    end
  end

  class SeekerAdded < Seeker
    def criteria
      Proc.new { |preventry, currentry| !currentry && preventry }
    end
  end

  class SeekerRemoved < Seeker
    def criteria
      Proc.new { |preventry, currentry| !preventry && currentry }
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
