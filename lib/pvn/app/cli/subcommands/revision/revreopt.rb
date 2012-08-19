#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/app/cli/subcommands/revision/revopt'
require 'pvn/revision/entry'
require 'svnx/log/command'

module PVN
  # A revision that is also set by -N and +N.
  class RevisionRegexpOption < RevisionOption
    POS_NEG_NUMERIC_RE = Regexp.new('^[\-\+]?\d+$')
    # TAG_RE = Regexp.new('^([\-\+]?\d+)|(-r(.*))$')
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

    def xxx_set_value val
      info "val: #{val}"
      if md = TAG_RE.match(val)
        super md[1]
      else
        super nil
      end
    end

    def post_process optset, unprocessed
      info "value: #{value}".blue

      md = TAG_RE.match value

      info "md: #{md.inspect}"
      
      return if md[2]

      info "md: #{md.inspect}".magenta

      logforrev = SVNx::LogCommandLine.new unprocessed[0]
      logforrev.execute
      xmllines = logforrev.output

      revargs = [ value ]

      @value = nil

      revargs.each do |revarg|
        info "revarg: #{revarg}".green
        reventry = PVN::Revisionxxx::Entry.new :value => revarg, :xmllines => xmllines.join('')
        revval   = reventry.value.to_s

        if @value
          @value << ":" << revval
        else
          @value = revval
        end
      end
    end
  end
end
