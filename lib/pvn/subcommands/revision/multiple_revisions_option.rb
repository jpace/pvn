#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/subcommands/revision/revision_regexp_option'

module PVN
  # A revision option with multiple values.
  class MultipleRevisionsRegexpOption < RevisionRegexpOption
    REVISION_DESCRIPTION = RevisionRegexpOption::REVISION_DESCRIPTION + [ "Multiple revisions can be specified." ]
    
    def set_value val
      currval = value
      if currval
        super [ currval, val ].flatten
      else
        super [ val ]
      end
    end

    def resolve_value optset, unprocessed
      newvalues = Array.new
      currvalues = value

      currvalues.each do |currval|
        md = TAG_RE.match currval
        if md
          convval = md[2] ? md[3] : relative_to_absolute(currval, unprocessed[0])
          newvalues << convval
        else
          newvalues << currval
        end
      end

      @value = newvalues
    end
  end
end
