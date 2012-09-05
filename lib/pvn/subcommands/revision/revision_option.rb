#!/usr/bin/ruby -w
# -*- ruby -*-

require 'riel'
require 'rubygems'
require 'synoption/option'
require 'svnx/log/command'
require 'pvn/revision/entry'

module PVN
  class RevisionOption < Option
    attr_accessor :fromdate
    attr_accessor :todate

    REVISION_DESCRIPTION = [ "revision to apply.",
                             "ARG can be relative, of the form:",
                             "    +N : N revisions from the BASE",
                             "    -N : N revisions from the HEAD,",
                             "         when -1 is the previous revision" ,
                           ]

    POS_NEG_NUMERIC_RE = Regexp.new('^[\-\+]\d+$')
    
    def initialize revargs = Hash.new
      @fromdate = nil
      @todate = nil
      super :revision, '-r', REVISION_DESCRIPTION, nil, revargs
    end

    def to_svn_revision_date date
      '{' + date.to_s + '}'
    end
    
    def value
      val = nil
      if @fromdate
        val = to_svn_revision_date @fromdate
      end

      if @todate
        val = val ? val + ':' : ''
        val += to_svn_revision_date @todate
      end

      if val
        val
      else
        super
      end
    end

    def head?
      value.nil? || value == 'HEAD'
    end

    def resolve_value optset, unprocessed
      val = value
      if POS_NEG_NUMERIC_RE.match val
        @value = relative_to_absolute val, unprocessed[0]
      end
    end

    def relative_to_absolute rel, path
      limit = rel[0, 1] == '-' ? rel.to_i.abs : nil
      xmllines = run_log_command limit, path

      reventry = PVN::Revision::Entry.new :value => rel, :xmllines => xmllines
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
