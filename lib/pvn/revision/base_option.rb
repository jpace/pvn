#!/usr/bin/ruby -w
# -*- ruby -*-

require 'synoption/option'
require 'svnx/log/command'

module PVN
  class BaseRevisionOption < Option
    REVISION_DESCRIPTION = [ "revision to apply.",
                             "ARG can be relative, of the form:",
                             "    +N : N revisions from the BASE",
                             "    -N : N revisions from the HEAD,",
                             "         when -1 is the previous revision" ,
                           ]
    
    def head?
      value.nil? || value == 'HEAD'
    end

    def resolve_value optset, unprocessed
      val = value
      if PVN::Revision::RELATIVE_REVISION_RE.match val
        @value = relative_to_absolute val, unprocessed[0]
      end
    end

    def relative_to_absolute rel, path
      limit = rel[0, 1] == '-' ? rel.to_i.abs : nil
      xmllines = run_log_command limit, path

      # This is Argument, not Range, because we're getting the value
      reventry = PVN::Revision::Argument.new rel, xmllines
      revval   = reventry.value.to_s
      revval
    end

    def run_log_command limit, path
      cmdargs = SVNx::LogCommandArgs.new :limit => limit, :path => path, :use_cache => false
      cmd = SVNx::LogCommand.new cmdargs
      cmd.execute
    end

    def entry
    end
  end
end
