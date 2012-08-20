#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/app/cli/subcommands/revision/revopt'

module PVN
  # A revision that is also set by -N and +N.
  class RevisionRegexpOption < PVN::RevisionOption
    POS_NEG_NUMERIC_RE = Regexp.new('^[\-\+]?\d+$')
    TAG_RE = Regexp.new('^(?:([\-\+]\d+)|(-r(.*)))$')

    REVISION_DESCRIPTION = [ "revision to apply.",
                             "ARG can be relative, of the form:",
                             "    +N : N revisions from the BASE",
                             "    -N : N revisions from the HEAD,",
                             "         when -1 is the previous revision" ,
                           ]
    
    def initialize revargs = Hash.new
      info "revargs: #{revargs}".on_blue
      revargs[:regexp] = TAG_RE
      super
    end

    def post_process optset, unprocessed
      val = value
      info "val: #{val}".blue

      md = TAG_RE.match val
      super unless md[2]
    end
  end
end
