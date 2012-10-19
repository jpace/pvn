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
                "matched." ]
    
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

      path = paths[0]
      
      # should I embed glark in pvn?

      entries = find_log_entries path
      info "entries: #{entries}"
      entries.each do |entry|
        info "entry: #{entry}"
      end
    end

    # here is the seekiness, a 40 year old algorithm
    def seek entries, pattern, from, to
      
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
