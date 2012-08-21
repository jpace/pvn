#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/app/cli/subcommands/revision/revision_regexp_option'
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

        if md
          convval = md[2] ? md[3] : relative_to_absolute(currval, unprocessed[0])
          newvalues << convval
        else
          newvalues << currval
        end
      end

      info "newvalues: #{newvalues}".on_blue

      @value = newvalues
    end
  end
end
