#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/cat/command'
require 'pvn/log/entries'

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
        $io.puts "path: #{@path} revision: #{@entries[ref.index].revision}"
        $io.puts "#{@path}:#{ref.lnum}: #{ref.line}"
      end
    end

    def seek_for criteria
      prevref = nil

      (0 ... @entries.size).each do |idx|
        entry = @entries[idx]
        ref = matches? entry.revision

        if matchref = criteria.call(prevref, ref)
          return Match.new idx - 1, matchref[0], matchref[1]
        end

        if ref
          prevref = ref
        end
      end
      nil
    end

    def get_log_entries
      # these mock Log::Options, kind of:
      options = Object.new
      def options.limit; nil; end
      def options.verbose; nil; end
      def options.revision; nil; end
      def options.user; nil; end
      def options.use_cache; nil; end

      logentries = PVN::Log::Entries.new @path, options
      @entries = logentries.entries
    end
  end
end
