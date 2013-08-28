#!/usr/bin/ruby -w
# -*- ruby -*-

require 'synoption/option'
require 'svnx/exec'
require 'svnx/revision/argument'

module PVN
  class BaseRevisionOption < Synoption::Option
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
      if SVNx::Revision::RELATIVE_REVISION_RE.match val
        @value = relative_to_absolute val, unprocessed[0]
      end
    end

    def relative_to_absolute rel, path
      limit = rel[0, 1] == '-' ? rel.to_i.abs : nil
      entries = run_log_command limit, path
      
      # This is Argument, not Range, because we're getting the value
      reventry = SVNx::Revision::Argument.new rel, entries: entries
      reventry.value.to_s
    end
    
    def run_log_command limit, path
      logexec = SVNx::LogExec.new path: path, limit: limit, revision: nil, verbose: false, use_cache: false
      logexec.entries
    end

    def entry
    end
  end
end
