#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/cat/command'
require 'pvn/log/entries'

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
  end

  class Path
    include Loggable

    def initialize path, pattern, revision
      @path = path
      @pattern = pattern
      @revision = revision
      get_log_entries
    end

    def matches? entry
      contents = cat entry.revision
      contents.each_with_index do |line, lnum|
        # info "line: #{line}".cyan
        if line.index @pattern
          info "line: #{line}".red
          return [ entry, lnum, line ]
        end
      end
      nil
    end

    def cat revision
      info "path: #{@path}"
      info "revision: #{revision}"
      catargs = SVNx::CatCommandArgs.new :path => @path, :use_cache => true, :revision => revision
      cmd = SVNx::CatCommand.new catargs
      cmd.execute
    end

    def get_seek_criteria type = :added
      if type == :added
        Proc.new { |preventry, currentry| !currentry && preventry }
      else
        Proc.new { |preventry, currentry| !preventry && currentry }
      end
    end

    def seek type = :added
      criteria = get_seek_criteria type
      ref = seek_for criteria
      if ref
        # todo: use previous or current entry, and run through entry formatter in log:
        log ref.entry.inspect.red
        entry = @entries[ref.index]
        info "entry: #{entry}"
        $io.puts "#{@path} -r#{@entries[ref.index].revision}:#{@entries[ref.index + 1].revision}".bold
        $io.puts "#{@path}:#{ref.lnum}: #{ref.line.chomp}".bold.black.on_yellow
      else
        $io.puts "not found in revisions: #{@entries[-1].revision} .. #{@entries[0].revision}".bold
      end
    end

    def seek_for criteria
      prevref = nil

      (0 ... @entries.size).each do |idx|
        entry = @entries[idx]
        ref = matches? entry

        if idx == 0
          prevref = ref
          next
        end

        info "idx: #{idx}; entry: #{entry}"
        info "ref: #{ref}; prevref: #{prevref}"

        if matchref = criteria.call(prevref, ref)
          info "matchref: #{matchref}"
          return Match.new idx - 1, matchref[1], matchref[2], matchref[0]
        end
        
        info "ref: #{ref}"

        if ref
          prevref = ref
        end
      end
      nil
    end

    def get_log_entries
      rev = if @revision
              if @revision.size == 1
                [ @revision[0], 'HEAD' ].join(':')
              else
                @revision.join(':')
              end
            else
              nil
            end
      
      logentries = PVN::Log::Entries.new @path, PathLogOptions.new(rev)
      @entries = logentries.entries
    end
  end
end
