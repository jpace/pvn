#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/seek/options'
require 'pvn/command/command'

module PVN::Seek
  class Command < PVN::Command::Command

    subcommands [ "seek" ]
    description "Searches through revisions for a pattern match."
    usage       "[OPTIONS] FILE..."
    summary   [ "Goes through a set of revisions, looking for when a pattern",
                "first matched a line within a file." ]
    
    # summary   [ "Goes through a set of revisions, looking for when a pattern",
    #             "matched (the default), or when a pattern does not match.",
    #             "This command therefore shows when a file changed to add",
    #             "or remove something such as a method." ]
    
    optscls

    example "pvn seek 'raise \w+Exception' foo.rb", "Shows when 'raise \w+Exception was added, through all revisions."
    # example "pvn seek -r137:211 'raise \w+Exception' foo.rb", "As above, but only between revisions 137 and 211."
    # example "pvn seek --no-match 'void\s+reinitialize()' *.java", "Looks through Java files for when 'void reinitialize() does _not_ match."

    def init options
      info "options: #{options.inspect}".red

      paths = options.paths

      pattern = paths.shift
      info "pattern: #{pattern}"

      paths = %w{ . } if paths.empty?
      info "paths: #{paths}".cyan

      # can handle only one path for now

      @path = paths[0]
      
      # should I embed glark in pvn?

      entries = find_log_entries @path
      seek entries, pattern, 0, entries.size
    end

    def matches? contents, pattern
      contents.each_with_index do |line, idx|
        # info "line: #{line}".cyan
        if line.index pattern
          info "line: #{line}".red
          return [ idx, line ]
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

    def seek entries, pattern, from, to
      info "from: #{from}".cyan
      info "to: #{to}".cyan

      midpt = from + (to - from) / 2
      return nil if midpt + 1 >= to

      entry = entries[midpt]
        
      lines = cat entry.revision
      info "entry.revision: #{entry.revision}"
      info "lines: #{lines.size}"
      
      if ref = matches?(lines, pattern)
        prevrev = entries[midpt + 1].revision
        info "prevrev: #{prevrev}"
        prevlines = cat prevrev
        info "prevlines: #{prevlines.size}"
        
        if !matches?(prevlines, pattern)
          info "ref: #{ref}"
          $io.puts "path: #{@path} revision: #{entry.revision}"
          $io.puts "#{@path}:#{ref[0]}: #{ref[1]}"
        else
          seek entries, pattern, midpt, to
        end
      else
        seek entries, pattern, from, midpt + 1
      end
    end

    ### $$$ this is sliced from Log::Command, from which many options will apply
    ### here (limit, user, revision)
    def find_log_entries path
      cmdargs = Hash.new
      cmdargs[:path] = path
      cmdargs[:use_cache] = false

      logargs = SVNx::LogCommandArgs.new cmdargs
      elmt    = PVN::IO::Element.new :local => path || '.'
      log     = elmt.log logargs
      entries = log.entries
    end
  end
end
