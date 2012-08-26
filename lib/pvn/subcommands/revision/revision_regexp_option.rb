#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/subcommands/revision/revision_option'

module PVN
  # A revision that is also set by -N and +N.
  class RevisionRegexpOption < PVN::RevisionOption
    TAG_RE = Regexp.new('^(?:([\-\+]\d+)|(-r(.+)))$')

    REVISION_DESCRIPTION = [ "revision to apply.",
                             "ARG can be relative, of the form:",
                             "    +N : N revisions from the BASE",
                             "    -N : N revisions from the HEAD,",
                             "         when -1 is the previous revision" ,
                           ]
    
    def initialize revargs = Hash.new
      # info "revargs: #{revargs}"
      revargs[:regexp] = TAG_RE
      super
    end

    def resolve_value optset, unprocessed
      val = value
      # info "val: #{val}"

      md = TAG_RE.match val
      # info "md: #{md.inspect}"

      if md && md[3]
        # info "md[3]: #{md[3]}"
        @value = md[3]
      end
      
      super
    end
  end
end
