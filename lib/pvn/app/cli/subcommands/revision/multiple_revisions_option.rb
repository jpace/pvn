#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/app/cli/subcommands/revision/revreopt'
require 'pvn/revision/entry'
require 'svnx/log/command'

module PVN
  # A revision option with multiple values.
  class MultipleRevisionsRegexpOption < RevisionRegexpOption
    REVISION_DESCRIPTION = [ "revision to apply.",
                             "ARG can be relative, of the form:",
                             "    +N : N revisions from the BASE",
                             "    -N : N revisions from the HEAD,",
                             "         when -1 is the previous revision" ,
                             "Multiple revisions can be specified." ,
                           ]
    
    # this should be if :several:
    def set_value val
      info "val: #{val.inspect}".on_black
      info "current: #{value}".on_blue
      currval = value
      if currval
        super [ currval, val ].flatten
      else
        super [ val ]
      end
    end

    def post_process optset, unprocessed
      info "value: #{value}".blue

      newvalues = Array.new
      currvalues = value

      currvalues.each do |currval|
        info "currval: #{currval}"
        
        md = TAG_RE.match currval

        info "md: #{md.inspect}"
        
        if md[2]
          @newvalues << currval
          next
        end

        logforrev = SVNx::LogCommandLine.new unprocessed[0]
        logforrev.execute
        xmllines = logforrev.output

        info "currval: #{currval}".green
        reventry = PVN::Revisionxxx::Entry.new :value => currval, :xmllines => xmllines.join('')
        revval   = reventry.value.to_s

        info "revval: #{revval}".green

        newvalues << revval
      end

      info "newvalues: #{newvalues}".on_blue

      @value = newvalues
    end
  end
end
