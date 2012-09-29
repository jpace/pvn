#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/revision/revision_option'

module PVN
  # A revision that is also set by -N and +N.
  class RevisionRegexpOption < PVN::RevisionOption
    TAG_RE = Regexp.new '^(?:([\-\+]\d+)|(-r(.+)))$'

    REVISION_DESCRIPTION = [ "revision to apply.",
                             "ARG can be relative, of the form:",
                             "    +N : N revisions from the BASE",
                             "    -N : N revisions from the HEAD,",
                             "         when -1 is the previous revision" ,
                           ]
    
    def initialize revargs = Hash.new
      revargs[:regexp] = TAG_RE
      super
    end
    
    def resolve_value optset, unprocessed
      val = value
      md  = TAG_RE.match val

      if md && md[3]
        @value = md[3]
      end
      
      super
    end
  end
end
