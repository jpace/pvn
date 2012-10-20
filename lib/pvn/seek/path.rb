#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/cat/command'

module PVN::Seek
  class Match
    attr_reader :index
    attr_reader :lnum
    attr_reader :line
    
    def initialize index, lnum, line
      @index = index
      @lnum = lnum
      @line = line
    end
  end

  class Path
    include Loggable

    def initialize path, pattern
      @path = path
      @pattern = pattern
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
      catargs = SVNx::CatCommandArgs.new :path => @path, :use_cache => false, :revision => revision
      cmd = SVNx::CatCommand.new catargs
      cmd.execute
    end

    def seek
      ref = seek_when_added
      if ref
        $io.puts "path: #{@path} revision: #{@entries[ref.index].revision}"
        $io.puts "#{@path}:#{ref.lnum}: #{ref.line}"
      end
    end

    def seek_for criteria
      prevref = nil

      (0 ... @entries.size).each do |idx|
        info "idx: #{idx}"
        entry = @entries[idx]
        info "entry: #{entry}"

        ref = matches? entry.revision
        info "ref: #{ref}".yellow

        if matchref = criteria.call(prevref, ref)
          return Match.new idx - 1, matchref[0], matchref[1]
        end

        if ref
          prevref = ref
        end
      end
      nil
    end

    def seek_when_added
      criteria = Proc.new { |prevref, ref| !ref && prevref }
      seek_for criteria
    end

    def seek_when_removed
      criteria = Proc.new { |prevref, ref| !prevref && ref }
      seek_for criteria
    end

    ### $$$ this is sliced from Log::Command, from which many options will apply
    ### here (limit, user, revision)
    
    def get_log_entries
      cmdargs = Hash.new
      cmdargs[:path] = @path
      cmdargs[:use_cache] = false

      logargs = SVNx::LogCommandArgs.new cmdargs
      elmt    = PVN::IO::Element.new :local => @path || '.'
      log     = elmt.log logargs
      @entries = log.entries
    end
  end
end
