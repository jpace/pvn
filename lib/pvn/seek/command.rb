#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/seek/options'
require 'pvn/command/command'
require 'pvn/seek/path'

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
      seekpath = Path.new paths[0], pattern
      seekpath.seek 
    end
  end
end