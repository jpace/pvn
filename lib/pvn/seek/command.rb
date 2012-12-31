#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/seek/options'
require 'pvn/command/command'
require 'pvn/seek/path'
require 'rainbow'

module PVN::Seek
  class Command < PVN::Command::Command

    subcommands [ "seek" ]
    description "Searches through revisions for a pattern match."
    usage       "[OPTIONS] FILE..."
    summary   [ "Looks through revisions and displays (a la grep) the most ",
                "recent revision when the given pattern matched. In the case ",
                "of the `--no-match` argument, the displayed revision is the most ",
                "recent one in which the pattern did not match. ",
                "This command therefore shows when a file was changed to add ",
                "or remove something such as a method." ]
    
    optscls

    example "pvn seek 'raise \\w+Exception' foo.rb", "Shows when 'raise \\w+Exception was added, through all revisions."
    # example "pvn seek -r137:212 'raise \w+Exception' foo.rb", "As above, but only between revisions 137 and 212."
    example "pvn seek --removed 'void\\s+reinitialize()' *.java", "Looks through Java files for the latest revision when 'void reinitialize() does not match."

    def init options
      paths = options.paths
      pattern = paths.shift
      
      raise "error: no pattern given to seek command" unless pattern

      paths = %w{ . } if paths.empty?
      seektype = options.removed ? :removed : :added

      # can handle only one path for now
      seekpath = Path.new paths[0]
      seekpath.seek seektype, pattern, options.revision, options.color
    end
  end
end
