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

    def seek from = 0, to = @entries.size
      ref = seek_when_added from, to
      if ref
        $io.puts "path: #{@path} revision: #{@entries[ref.index].revision}"
        $io.puts "#{@path}:#{ref.lnum}: #{ref.line}"
      end
    end

    def seek_when_added from = 0, to = @entries.size
      info "from: #{from}"
      info "to: #{to}"

      prevref = nil

      idx = from
      while idx < to
        info "idx: #{idx}"
        entry = @entries[idx]
        info "entry: #{entry}"

        ref = matches? entry.revision
        info "ref: #{ref}".yellow

        if !ref && prevref
          return Match.new(idx - 1, prevref[0], prevref[1])
        end

        if ref
          prevref = ref
        end

        idx += 1
      end
      nil
    end
    
    def seek_when_removed from = 0, to = @entries.size
      info "from: #{from}"
      info "to: #{to}"

      return nil if from == to
      midpt = from + (to - from) / 2

      info "midpt: #{midpt}"
      entry = @entries[midpt]
      info "entry: #{entry}"
      
      if ref = matches?(entry.revision)
        info "midpt: #{midpt}"
        prevmatch = seek_when_removed from, midpt
        info "prevmatch: #{prevmatch}".yellow
        prevmatch || Match.new(midpt, ref[0], ref[1])
      else
        seek_when_added midpt + 1, to
      end
    end

    def xxxseek_when_removed from = 0, to = @entries.size
      entries = @entries
      
      info "from: #{from}".cyan
      info "to: #{to}".cyan

      midpt = from + (to - from) / 2
      return nil if midpt - 1 < from

      entry = entries[midpt]
      
      if ref = matches?(entry.revision)
        # entries are sorted most to least recent:
        nextrev = entries[midpt - 1].revision
        info "nextrev: #{nextrev}".red
        
        if matches? nextrev
          seek from, midpt - 1
        else
          info "ref: #{ref}"
          $io.puts "path: #{@path} revision: #{nextrev}"
          $io.puts "#{@path}:#{ref[0]}: #{ref[1]}"
        end
      else
        seek midpt, to
      end
    end

    def xxxseek_when_added from = 0, to = @entries.size
      entries = @entries
      
      info "from: #{from}".cyan
      info "to: #{to}".cyan

      midpt = from + (to - from) / 2
      return nil if midpt + 1 >= to

      entry = entries[midpt]
      
      if ref = matches?(entry.revision)
        # entries are sorted most to least recent:
        prevrev = entries[midpt + 1].revision
        info "prevrev: #{prevrev}"
        
        if matches? prevrev
          seek midpt, to
        else
          info "ref: #{ref}"
          $io.puts "path: #{@path} revision: #{entry.revision}"
          $io.puts "#{@path}:#{ref[0]}: #{ref[1]}"
        end
      else
        seek from, midpt + 1
      end
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
