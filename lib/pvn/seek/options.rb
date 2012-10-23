#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/revision/multiple_revisions_option'
require 'pvn/command/options'

module PVN::Seek
  class MatchOption < PVN::BooleanOption
    def initialize optargs = Hash.new
      opts = Hash.new
      opts[:negate] = '--nomatch', '-M'
      super :match, '-m', 'find where the pattern matched', true, opts
    end
  end

  class RemovedOption < PVN::BooleanOption
    def initialize optargs = Hash.new
      opts = Hash.new
      super :removed, '-M', 'find where the pattern did not match', false, opts
    end
  end

  class SeekRevisionOption < PVN::MultipleRevisionsRegexpOption
    REVISION_DESCRIPTION = PVN::RevisionRegexpOption::REVISION_DESCRIPTION + 
      [
       'Zero, one, or two revisions may be specified:',
       '    A single revision is the equivalent of -rN:HEAD.',
       '    Multiple revisions are the equivalent of -rM:N.'
      ]
    
    def resolve_value optset, unprocessed
      super optset, unprocessed[-1, 1]
    end

    def description
      REVISION_DESCRIPTION
    end
  end

  class OptionSet < PVN::Command::OptionSet
    has_option :revision, SeekRevisionOption
    # has_option :match,    MatchOption
    has_option :removed,  RemovedOption
    has_option :help,     PVN::Command::HelpOption
  end
end
