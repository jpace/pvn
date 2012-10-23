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

    def matches? revision
      contents = cat revision
      contents.each_with_index do |line, lnum|
        # info "line: #{line}".cyan
        if line.index @pattern
          info "line: #{line}".red
          return [ lnum, line ]
        end
      end
      false
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
        Proc.new { |prevref, ref| !ref && prevref }
      else
        Proc.new { |prevref, ref| !prevref && ref }
      end
    end

    def seek type = :added
      criteria = get_seek_criteria type
      ref = seek_for criteria
      if ref
        log ref.entry.inspect.red
        $io.puts "#{@path} revision: #{@entries[ref.index].revision}".bold
        $io.puts "#{@path}:#{ref.lnum}: #{ref.line.chomp}".bold.black.on_yellow
      end
    end

    def seek_for criteria
      prevref = nil

      (0 ... @entries.size).each do |idx|
        entry = @entries[idx]
        ref = matches? entry.revision

        if matchref = criteria.call(prevref, ref)
          return Match.new idx - 1, matchref[0], matchref[1], entry
        end

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
